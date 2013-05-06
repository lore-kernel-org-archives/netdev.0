From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Mon, 6 May 2013 14:11:06 +0200
Message-ID: <20130506121106.GA25615@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
 <20130504225715.GB24276@amd.pavel.ucw.cz>
 <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
 <20130505000528.GA25454@amd.pavel.ucw.cz>
 <20130505091844.GC22239@gmail.com>
 <20130506085547.GC13861@dyad.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>, Colin Cross <ccross@android.com>,
	Andrew Morton <akpm@osdl.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Len Brown <len.brown@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Paul Walmsley <paul@pwsan.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
	Linux PM list <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130506085547.GC13861@dyad.programming.kicks-ass.net>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1;2403;0cOn Mon 2013-05-06 10:55:47, Peter Zijlstra wrote:
> On Sun, May 05, 2013 at 11:18:44AM +0200, Ingo Molnar wrote:
> > That's the old 32-bit x86 trick to compute 'current' from the kernel stack 
> > pointer.
> > 
> > It can be done better - for example on platforms with optimized percpu 
> > variables (x86-64) it looks like this:
> 
> Doesn't i386 have all the funny per-cpu stuff too? So the only reason it still
> does the fugly stack based thing is because nobody could be arsed to do the
> work of converting it.

(Note that the quoted example was from ARM. But also note that the
percpu stuff requires memory access, so...)
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
