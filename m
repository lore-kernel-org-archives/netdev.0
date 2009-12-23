From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 16:02:10 -0800
Message-ID: <20091223000210.GA6518@sequoia.sous-sol.org>
References: <4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws> <4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <20091222162110.GG10314@basil.fritz.box> <4B30F375.6050103@codemonkey.ws> <20091222173326.GH10314@basil.fritz.box> <4B3136AA.50204@codemonkey.ws>
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
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B3136AA.50204@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Anthony Liguori (anthony@codemonkey.ws) wrote:
> The
> virtio-net setup probably made extensive use of pinning and other tricks  
> to make things faster than a normal user would see them.  It ends up  
> creating a perfect combination of batching which is pretty much just  
> cooking the mitigation schemes to do extremely well for one benchmark.

Just pinning, the rest is stock virtio features like mergeable rx buffers,
GRO, GSO (tx mitigation is actually disabled).  Certainly doesn't show
throughput in terms of cpu cycle cost (scaling) nor latency per-packet
(exit and mitigation).

thanks,
-chris
