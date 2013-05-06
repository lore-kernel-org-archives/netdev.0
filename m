From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Mon, 06 May 2013 22:06:05 +0200
Message-ID: <2307385.H0igaKqWJi@vostro.rjw.lan>
References: <1367615050-3894-1-git-send-email-ccross@android.com> <CAMbhsRRcfpXBGAPThjrmB_judgn85TioR_6A6qwh_fBQCent7A@mail.gmail.com> <20130506193307.GD800@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Paul Walmsley <paul@pwsan.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oleg Nesterov <oleg@redhat.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ben Chan <benchan@chromium.org>
To: Tejun Heo <tj@kernel.org>, Colin Cross <ccross@android.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130506193307.GD800@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, May 06, 2013 12:33:07 PM Tejun Heo wrote:
> Hello,
> 
> On Mon, May 06, 2013 at 12:30:19PM -0700, Colin Cross wrote:
> > > I don't care about %current change, especially given that it's a debug
> > > interface but that really should be a separate patch, so please split
> > > it out if you want it (and I think we want it).
> > 
> > The current change was requested by akpm and was part of the original
> > patch.  Is it really worth confusing the history of this patch even
> > more, applying it the first time, reverting it, and then applying it
> > again in two parts?
> 
> I don't know.  The patch seems confusing to me.  It really is about
> adding single lockdep annotation but comes with other changes.  I
> don't think it's a big deal either way but at least we wouldn't be
> having this %current vs. @tsk conversation which is mostly irrelevant
> to the actual proposed change, right?  It really should have been a
> separate patch from the beginning.  Just refer to the original commit
> and explain what happened?

Yeah.  I'd prefer that very much.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
