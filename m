From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 17:21:10 +0100
Message-ID: <20091222162110.GG10314@basil.fritz.box>
References: <4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com> <4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws> <4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws> <4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754020AbZLVQVV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B30E654.40702@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So far, the only actual technical advantage I've seen is that vbus avoids 
> EOI exits.  

The technical advantage is that it's significantly faster today.

Maybe your proposed alternative is as fast, or maybe it's not. Who knows?

> We think we understand why vbus does better than the current userspace 
> virtio backend.  That's why we're building vhost-net.  It's not done yet, 
> but our expectation is that it will do just as well if not better.

That's the vapourware vs working code disconnect I mentioned. One side has hard
numbers&working code and the other has expectations. I usually find it sad when the
vapourware holds up the working code.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
