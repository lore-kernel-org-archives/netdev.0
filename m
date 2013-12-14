From: Joe Perches <joe@perches.com>
Subject: Re: bnx2x_sriov.c: Missing switch/case breaks?
Date: Sat, 14 Dec 2013 09:49:59 -0800
Message-ID: <1387043399.2276.12.camel@joe-AO722>
References: <1386975703.2479.48.camel@joe-AO722>
	 <979A8436335E3744ADCD3A9F2A2B68A52AF1A735@SJEXCHMB10.corp.ad.broadcom.com>
	 <1387004267.2276.7.camel@joe-AO722>
	 <979A8436335E3744ADCD3A9F2A2B68A52AF1A7FF@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <ariele@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF1A7FF@SJEXCHMB10.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-12-14 at 13:26 +0000, Yuval Mintz wrote:
> > > The `vfop' part of the code contains a lot of usage of the
> > `bnx2x_vfop_finalize()',
> > > which either goto or return at the end of almost every case.
> > > "Normal" analysis tools/scripts fail to recognize them as  valid case
> > breaks.
> > >
> > > Adding `fallthrough' comments would make little sense, as this is not the
> > real
> > > behavior; Perhaps we need some alternative comment? (something in the
> > line
> > > of `macro case break')
> > 
> > No idea.  It's certainly an ugly macro.
> > 
> 
> True.
[]
> > maybe there should be a break after most all
> > uses of this macro anyway.  When next is
> 
> Won't some static code analysis tools regard such `break' calls as
> unreachable code?

I suppose that maybe true,
but this could also work...

		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT); 
				/* Ugly goto|return macro, not fall-through */

;)
