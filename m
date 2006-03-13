From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 13 Mar 2006 14:13:05 -0800
Message-ID: <20060313141305.0cd4fe97.akpm@osdl.org>
References: <200603130139.k2D1dpSQ021279@shell0.pdx.osdl.net>
	<20060312.180802.13404061.davem@davemloft.net>
	<200603132105.32794.ioe-lkml@rameria.de>
	<20060313202242.GC27761@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@rameria.de, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932508AbWCMWPz@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060313202242.GC27761@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> On Mon, Mar 13, 2006 at 09:05:31PM +0100, Ingo Oeser wrote:
> > From: Ingo Oeser <ioe-lkml@rameria.de>
> > 
> > Fold __scm_send() into scm_send() and remove that interface completly
> > from the kernel.
> 
> Whoa, what are you doing here?
>

scm_send() and scm_recv() are already uninlined in Dave's tree - this patch
does further consolidation.

>  Uninlining scm_send() is a Bad Thing to do 
> given that scm_send() is in the AF_UNIX hot path.

scm_send() and scm_recv() are in _two_ AF_UNIX hotpaths...
