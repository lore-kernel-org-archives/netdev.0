From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: linux-wireless mailing list
Date: Wed, 03 Mar 2004 22:08:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40469DA1.9090502@pobox.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@hpl.hp.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pavel Roskin wrote:
> Hello!
> 
> I believe the developers of Linux wireless drivers need a separate mailing
> list, preferably called linux-wireless at vger.kernel.org.  I don't expect
> it to have heavy traffic, but there should be a definitive forum for
> discussing issues common for wireless drivers on Linux.

I do not object to such a list, but I would respectfully request that 
all development matters be cross-posted to netdev@oss.sgi.com.  That's 
where the network developers hang out.

Now I present my opinions :)

> I expect following topics to be discussed:
> 
> Wireless Extensions.  I highly respect Jean Tourrilhes who is doing this
> work.  I believe that driver and userspace developers should use this
> forum to discuss their needs and to provide feedback to Jean.

The wireless extensions are utility -- they work, but are not beautiful. 
  I am presently writing the driver for the RealTek wireless card, and 
in the process creating a small wireless driver API.  The ideal is to 
avoid ioctls, and instead to present extensible, type-safe interfaces. 
This is what I would like wireless extensions to morph into.


> Handling of 802.11 frames.  We may need common code to convert 802.11
> frames to 802.3 and possibly other standards.  Maybe some standards for
> 802.11 encapsulation and bridging could be discussed as well.

Absolutely.  David Miller, Arnaldo Carvalho de Melo, and myself all seem 
to feel that a net/802_11 directory and associated code would be useful. 
  There is definitely an area for code commonality across drivers.


> Sniffing.  We need a common standard how to pass raw frames and additional
> information to the userspace.  There are several de facto standards, but
> the lack of communication between developers makes those standards less
> useful.  For example, Prism2 headers were meant as highly extensible, but
> libpcap expects them to be of fixed size.  It's an obvious failure to
> communicate the intentions of the standard.

Agreed.


> Encryption.  There are wireless specific encryption issues.  Host based
> WEP support needs RC4 cipher in the kernel.  There's not much to discuss
> here, but the lack of RC4 in the kernel may indicate that Linux wireless
> developers are not acting together to make it happen.  The patch does
> exist.

Send the patch to netdev!  ;-)  This should be the easy part.


> Other interfaces between drivers and the userspace.  There should be one
> place to discuss whether wireless drivers should be using
> netif_carrier_on/off, ethtool and mii-tool support.  Again, there is not
> much to discuss, but it's much much worse if the same questions are
> discussed in different forums and every driver takes its own approach.

netdev is that place ;-)

Best regards and welcome,

	Jeff
