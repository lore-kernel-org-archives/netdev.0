From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 11:39:55 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0912221137380.29381@makko.or.mcafeemobile.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com> <4B311ADA.4000700@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754815AbZLVTkH@vger.kernel.org>
In-Reply-To: <4B311ADA.4000700@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Dec 2009, Gregory Haskins wrote:

> On 12/22/09 1:53 PM, Avi Kivity wrote:
> > I asked why the irqfd/ioeventfd mechanisms are insufficient, and you did not reply.
> > 
> 
> BTW: the ioeventfd issue just fell through the cracks, so sorry about
> that.  Note that I have no specific issue with irqfd ever since the
> lockless IRQ injection code was added.
> 
> ioeventfd turned out to be suboptimal for me in the fast path for two
> reasons:
> 
> 1) the underlying eventfd is called in atomic context.  I had posted
> patches to Davide to address that limitation, but I believe he rejected
> them on the grounds that they are only relevant to KVM.

I thought we addressed this already, in the few hundreds of email we 
exchanged back then :)



> 2) it cannot retain the data field passed in the PIO.  I wanted to have
> one vector that could tell me what value was written, and this cannot be
> expressed in ioeventfd.

Like might have hinted in his reply, couldn't you add data support to the 
ioeventfd bits in KVM, instead of leaking them into mainline eventfd?



- Davide
