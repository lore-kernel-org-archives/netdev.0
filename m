From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/2] NET: Multiqueue network device support.
Date: Mon, 9 Apr 2007 13:47:58 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329029E3EFE@orsmsx414.amr.corp.intel.com>
References: <20070409.134631.71091422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, "cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965693AbXDIUsG@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070409.134631.71091422.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Monday, April 09, 2007 1:47 PM
> To: Waskiewicz Jr, Peter P
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> jgarzik@pobox.com; cramerj; Kok, Auke-jan H; Leech, Christopher
> Subject: Re: [PATCH 2/2] NET: Multiqueue network device support.
> 
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 9 Apr 2007 13:43:11 -0700
> 
> > True, but the assignment for "dev" above also casts this void * to 
> > struct net_device *:
> > 
> >         dev = (struct net_device *)
> >                 (((long)p + NETDEV_ALIGN_CONST) & 
> ~NETDEV_ALIGN_CONST);
> >         dev->padded = (char *)dev - (char *)p;
> > 
> > Shall I remove my cast?
> 
> I think so.  Casts tend to be red flags during patch review, 
> so don't add them when not necessary and let's remove the 
> unnecessary ones too.

Will do.  On a side note, I don't see my patches landing on vger again.
Did they get munched, or is majordomo lagging a bit?

Thanks,

-PJ Waskiewicz
