From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 21:14:49 +0100
Message-ID: <20090312201449.95468832E8B8@gemini.denx.de>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org> <49B95907.4010404@weinigel.se> <20090312190416.GS425@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Christer Weinigel <christer@weinigel.se>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	dzu@denx.de
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43890 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbZCLUOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 16:14:54 -0400
Cc: Vladimir Khusainov <vlad@emcraft.com>,
	Nick Ivanter <nick@emcraft.com>,
	Sergei Poselenov <sposelenov@emcraft.com>
In-reply-to: <20090312190416.GS425@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sascha Hauer,

In message <20090312190416.GS425@pengutronix.de> you wrote:
>
> Great, but how does this help in setting the MAC address? This would
> just move this exact discussion to the dracut or whatever mailing list,
> but we would still be searching for a generic way to say
> eth0addr=00:01:02:03:04:05 and I bet the arguments stay the same.

Well, PowerPC uses the device tree for such information.  As  far  as
I've been told work is underway to extend the device tree support for
ARM, too.  [And U-Boot supports the device tree, of course.]

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Any sufficiently advanced technology is indistinguishable from magic.
                                                   - Arthur C. Clarke
