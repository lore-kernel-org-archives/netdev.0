From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 09:22:13 +0200
Message-ID: <20091222072213.GY4490@redhat.com>
References: <4B1D4F29.8020309@gmail.com>
 <20091218215107.GA14946@elte.hu>
 <4B2F9582.5000002@gmail.com>
 <4B2F978D.7010602@redhat.com>
 <4B2F9C85.7070202@gmail.com>
 <4B2FA42F.3070408@codemonkey.ws>
 <4B2FA655.6030205@gmail.com>
 <4B2FAE7B.9030005@codemonkey.ws>
 <4B2FB3F1.5080808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752576AbZLVHXG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B2FB3F1.5080808@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 21, 2009 at 12:44:17PM -0500, Gregory Haskins wrote:
> >  They should be relatively rare
> > because obtaining good receive batching is pretty easy.
> 
> Batching is poor mans throughput (its easy when you dont care about
> latency), so we generally avoid as much as possible.
> 
> > Considering
> > these are lightweight exits (on the order of 1-2us),
> 
> APIC EOIs on x86 are MMIO based, so they are generally much heavier than
> that.  I measure at least 4-5us just for the MMIO exit on my Woodcrest,
> never mind executing the locking/apic-emulation code.
> 
With x2apic EOIs are not MMIO any longer.

--
			Gleb.
