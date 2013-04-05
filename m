From: Dan Williams <dcbw@redhat.com>
Subject: Re: [Suggestion] ISDN: isdnloop: C grammar issue, '}' miss match
 'if' and 'switch' statement.
Date: Fri, 05 Apr 2013 15:37:27 -0500
Message-ID: <1365194247.22273.7.camel@dcbw.foobar.com>
References: <1364999477.13853.21.camel@edumazet-glaptop>
	 <CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com>
	 <515D3A09.7040202@asianux.com>
	 <20130404.140956.2233513394092413594.davem@davemloft.net>
	 <1365130824.25884.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gang.chen@asianux.com,
	torvalds@linux-foundation.org, eric.dumazet@gmail.com,
	mkubecek@suse.cz, fengguang.wu@intel.com, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162192Ab3DEUhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 16:37:02 -0400
In-Reply-To: <1365130824.25884.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 20:00 -0700, Joe Perches wrote:
> On Thu, 2013-04-04 at 14:09 -0400, David Miller wrote:
> > From: Chen Gang <gang.chen@asianux.com>
> > Date: Thu, 04 Apr 2013 16:30:01 +0800
> > >> Of course, nobody sane actually cares about ISDN any more, so I think
> > >> this is all pretty academic. I think even Germany (where ISDN *used*
> > >> to be very common due to telephone monopolies and odd rules) no longer
> > >> uses it. I can't imagine that anybody else does either.
> > >   can we delete it ?
> > I think the point is no that we can delete it, but rather that we
> > should concentrate our efforts on code that more people use rather
> > than trying to clean up antiquated code with very few users.
> 
> Very sensible.
> 
> I was going to see about moving drivers/isdn/hardware/eicon
> to staging but it seems the hardware is still for sale.
> 
> http://www.dialogic.com/en/products/media/diva/diva-bri-2.aspx
> 
> Anyone have suggestions on other obsolete isdn drivers that
> could be moved to staging for awhile before deletion?

Anything PCMCIA or ISA?  There are a number of them:

CONFIG_ISDN_DRV_AVMB1_B1ISA
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA
CONFIG_ISDN_DRV_AVMB1_AVM_CS
CONFIG_ISDN_DRV_AVMB1_T1ISA
CONFIG_HISAX_SEDLBAUER_CS
CONFIG_HISAX_ELSA_CS
CONFIG_HISAX_AVM_A1_CS
CONFIG_HISAX_TELES_CS
CONFIG_ISDN_DRV_ACT2000

That's all I can find in a quick look.

Dan
