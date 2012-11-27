From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Tue, 27 Nov 2012 04:36:56 -0800
Message-ID: <1354019816.7553.1585.camel@edumazet-glaptop>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
	 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
	 <1353800616.2590.4562.camel@edumazet-glaptop>
	 <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
	 <1353950255.7553.6.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tino Keitel <tino.keitel@tikei.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35192 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382Ab2K0Mg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 07:36:58 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so8073649iea.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 04:36:58 -0800 (PST)
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 10:36 +0100, Keitel, Tino (ALC NetworX GmbH)
wrote:
> On Mo, 2012-11-26 at 09:17 -0800, Eric Dumazet wrote:
> > On Mon, 2012-11-26 at 18:08 +0100, Keitel, Tino (ALC NetworX GmbH)
> > wrote:
> > > On Mo, 2012-11-26 at 08:34 -0800, Eric Dumazet wrote:
> > > > On Mon, 2012-11-26 at 11:01 +0100, Tino Keitel wrote:
> > > > > On Sat, Nov 24, 2012 at 15:43:36 -0800, Eric Dumazet wrote:
> > > > > 
> > > > > [...]
> > > > > 
> > > > > > Hmm, I wonder if BQL makes a particular bug showing more often.
> > > > > > 
> > > > > > I see gianfar uses a very small watchdog_timeo of 1 second, while many
> > > > > > drivers use 5 seconds.
> > > > > > 
> > > > > > What happens if you change this to 5 seconds ?
> > > > > 
> > > > > I still got the trace and a failing ptp client.
> > > > > 
> > > > 
> > > > Thanks. Is this bug easy to trigger ?
> > > > 
> > > > I suspect a core issue and a race, likely to happen on your (non x86)
> > > > hardware
> > > > 
> > > > Could you add the following debugging patch ?
> > > 
> > > No visible difference:
> > 
> > OK it seems you trigger the problem fast !
> > 
> > Please try the following as well :
> 
> Hi,
> 
> yes, it can be triggered within 2 minutes.
> 
> The patch makes no difference:

Can you reproduce the problem using a single cpu ?
