From: Gertjan van Wingerde <gwingerde@home.nl>
Subject: Re: [RFC] Wireless extensions rethink
Date: Tue, 15 Jun 2004 18:39:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CF263E.70009@home.nl>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Scott,

Sounds like a good idea. I'll start refactoring my work towards that approach. Please bear
with me for a couple of days and I'll post a draft patch for this.

--- Gertjan.


Feldman, Scott wrote:
>>I was thinking along the same lines, however I was taking the 
>>ethtool interface as the starting point (using a single ioctl 
>>for all wireless operations). The private handlers would just 
>>have to be converted to plain ioctls handled by the driver itself.
>>
>>The attached patch can be used as a starting point for this.
>>It is not complete (not by far), but it shows the basic structure.
>>I've called the structure wlantool_ops, again using the 
>>example set by ethtool.
>>
>>Comments?
> 
> 
> What if we just use the ethtool ioctl that's already defined, and extend
> ethtool with a wireless option:
> 
> ethtool -w DEVNAME \
> 	[ nwid N|off|on} ] \
> 	[ freq x.xx ] \
> 	[ mode ad-hoc|managed|master|repeater|... ] \
> 	[ sens N ] \
> 	[ ... ]
> 
> Each one of the sub-options to -w would have it's own ETHTOOL_[G|S]W...
> command as well as a type-safe ethtool_op.
> 
> Running ethtool DEVNAME dumps ETHTOOL_GW... :
> 
> Wireless settings for eth0:
>         nwid: AB34
>         freq: 2.422G
>         mode: managed
>         sens: -80
> 
> Good/bad idea?
> 
> -scott        
> 
> 
