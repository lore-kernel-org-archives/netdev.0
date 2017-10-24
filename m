From: Tuomas Tynkkynen <tuomas@tuxera.com>
Subject: Re: [PATCH 0/2] 9p: Fixes for hard-to-hit bugs
Date: Tue, 24 Oct 2017 04:41:08 +0300
Message-ID: <1508809268.9653.13.camel@tuxera.com>
References: <20170906145908.8082-1-tuomas@tuxera.com>
         <1506431414.20647.0.camel@tuxera.com>
         <20171020201125.GU21978@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <v9fs-developer@lists.sourceforge.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020201125.GU21978@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al,

On Fri, 2017-10-20 at 21:11 +0100, Al Viro wrote:
> On Tue, Sep 26, 2017 at 04:10:14PM +0300, Tuomas Tynkkynen wrote:
> > Hi Al,
> > 
> > On Wed, 2017-09-06 at 17:59 +0300, Tuomas Tynkkynen wrote:
> > > These two patches fix two hard-to-hit (but really annoying) bugs
> > > in
> > > 9p.
> > > The first one was posted earlier in February (with one R-b), the
> > > second
> > > is a new one.
> > > 
...
> > > 
> > 
> > Could you apply these? Thanks!
> 
> I can pick those, or, if you (or somebody else) are willing to
> actively
> maintain a 9p tree, you could start sending straight to Linus - up to
> you.

You can pick these up, I don't have plans for more patches right now
(unless we hit some new bugs that affect our workloads).

(FWIW there do lurk dragons there, at least 1) setxattr() with zero-
length value turns into a removexattr(), and 2) creat("foo", 0444)
fails due to the R/O perms when opening the writeback_fid. Fixes to
either didn't seem too easy...)

Thanks!

- Tuomas
