From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: Extend smc911x to support LAN921x chips - differences?
Date: Tue, 9 Sep 2008 18:18:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0809091814460.7385@axis700.grange>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34350 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757514AbYIIQKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 12:10:17 -0400
In-Reply-To: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steve,

On Tue, 9 Sep 2008, Steve.Glendinning@smsc.com wrote:

> Did you have the in-tree driver succesfully working with LAN9115?

I haven't used smc911x for a while, but last time I used it (around 
2.6.21, I think), I think, it worked. Was a completely different hardware 
though.

> The only hardware difference between the two is that LAN921[5678] has an
> Auto-MDIX PHY.  This adds a configuration bit in one of the 
> vendor-specific
> PHY registers to force the feature off, but it defaults to Auto-MDIX 
> enabled.
> All of the SCR and MAC registers (and the remaining PHY registers) are 
> *identical*, so any working driver should just need the ID register
> changing to recognise the newer part.

It works now! Just chose a wrong bus-width.

> Early revisions of LAN911X had a hardware bug which is most commonly
> experienced when joining/leaving multicast groups.  The smsc911x driver
> contains a workaround for this, but the in-tree driver does not.  LAN921X
> came after this was fixed in hardware, so this workaround is not 
> necessary.
> 
> The vast majority of users i've worked with have ended up using the
> out-of-tree smsc911x driver, as it "just works" on many platforms.
> I'll be re-submitting another candidate when I've finished working on the
> LAN9500 USB ethernet driver, but for now the latest submission:
> 
> http://marc.info/?l=linux-netdev&m=121240395122475&w=2

Thanks, I was about to try yours, was the last attempt to use the stock 
driver, and, perhaps, unfortunately for you, it worked:-)

Thanks again
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
