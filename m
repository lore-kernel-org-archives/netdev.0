From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Mon, 07 Jun 2004 13:52:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C4D595.4050801@candelatech.com>
References: <40C4C741.5040708@home.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gertjan van Wingerde <gwingerde@home.nl>
In-Reply-To: <40C4C741.5040708@home.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gertjan van Wingerde wrote:
> Hi Scott,
> 
> I was thinking along the same lines, however I was taking the ethtool
> interface as the starting point (using a single ioctl for all wireless
> operations). The private handlers would just have to be converted to
> plain ioctls handled by the driver itself.
> 
> The attached patch can be used as a starting point for this.
> It is not complete (not by far), but it shows the basic structure.
> I've called the structure wlantool_ops, again using the example set by
> ethtool.
> 
> Comments?

For what it's worth, I like the idea of using a single IOCTL similar
to ethtool...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
