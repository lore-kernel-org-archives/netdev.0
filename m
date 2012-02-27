From: "Rajashekhara, Sudhakar" <sudhakar.raj@ti.com>
Subject: RE: davinci_emac/mdio: SOFT_RESET of EMAC module resets MDIO on
 AM1808
Date: Mon, 27 Feb 2012 10:15:03 +0000
Message-ID: <B6A220404B6BFC4BBD2AB91C54D39DF43177683F@DBDE01.ent.ti.com>
References: <B6A220404B6BFC4BBD2AB91C54D39DF431775E1B@DBDE01.ent.ti.com>
 <1330092923-10899-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Gole, Anant" <anantgole@ti.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:33791 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534Ab2B0KPW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 05:15:22 -0500
In-Reply-To: <1330092923-10899-1-git-send-email-christian.riesch@omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christian,

On Fri, Feb 24, 2012 at 19:45:23, Christian Riesch wrote:
> Hello Sudhakar,
> 
> On Fri, Feb 24, 2012 at 2:02 PM, Rajashekhara, Sudhakar <sudhakar.raj@ti.com> wrote:
> > On Thu, Feb 23, 2012 at 14:39:49, Christian Riesch wrote:
> >> Hi,
> >> I observed this behavior on a Texas Instruments AM1808 SoC (AM1808
> >> experimenter's kit) running the current mainline kernel:
> >>

[snip]

> >>
> >> According to the AM1808 Technical Reference Manual (sections 18.2.14.1
> >> and 18.3.3.34 in [1]), writing a 1 to the EMAC_SOFTRESET register
> >> resets the EMAC module, but not the MDIO module. However, when I
> >> comment out the code above, the MDIO control register is not affected
> >> and the warning 'resetting idled controller' disappears.
> >>
> >
> > But this was not the case for me. Even after commenting out the above lines,
> > I could still see that MDIO was getting reset.
> 
> Uh, I am sorry. I forgot to mention that there is a second
> emac_write(EMAC_SOFTRESET,1); in emac_dev_stop() in davinci_emac.c. 
> This one must also be commented out to make the resetting idled controller 
> message go away.
> 
> The patch below shows that changes that I did. May I please ask you to try
> again with these changes?
> 

I was able to reproduce the issue. I'll debug this further and get back to you.

Regards,
Sudhakar
