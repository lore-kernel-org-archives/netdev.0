From: Ben Greear <greearb@candelatech.com>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Wed, 09 Jul 2003 10:15:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0C4DBD.8020007@candelatech.com>
References: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrius Kasparavicius <andrius@andrius.org>
In-Reply-To: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrius Kasparavicius wrote:
> hello, as far as i know, currently there is no native vlan support in
> network device drivers. I mean, always need patching MTU.. add 4 bytes..
> :-(
> 
> is there any problems to include full vlans support?

Intel's e100 driver (and all NICs supported by it) support vlans
fine, as do most of the GigE NICs.  Tulip does not, last I hear, though
a work-around patch has been around forever.  Realtek worked at one time,
not sure about now though...

Ben


> 
> 
> Andrius
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
