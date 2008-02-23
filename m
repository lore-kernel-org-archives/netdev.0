From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 0/8]: uninline & uninline
Date: Sat, 23 Feb 2008 20:06:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802232003380.30001@kivilampi-30.cs.helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080223000220.e9229c99.akpm@linux-foundation.org> <p734pbz95lx.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760288AbYBWSHI@vger.kernel.org>
In-Reply-To: <p734pbz95lx.fsf@bingen.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Feb 2008, Andi Kleen wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> 
> >> -41525  2066 f, 3370 +, 44895 -, diff: -41525  IS_ERR 
> >
> > This is a surprise.  I expect that the -mm-only
> > profile-likely-unlikely-macros.patch is the cause of this and mainline
> > doesn't have this problem.
> 
> Shouldn't they only have overhead when the respective CONFIG is enabled?

I uninlined those with allyesconfig. I'll anyway try later on without a 
number of debug related CONFIGs.


-- 
 i.
