From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Wed, 24 Aug 2016 10:03:16 -0400
Message-ID: <20160824140316.GB14309@csclub.uwaterloo.ca>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <20160823.094029.1244944495918162255.davem@davemloft.net>
 <1471973727.13300.162.camel@decadent.org.uk>
 <20160823.112406.549221808236512285.davem@davemloft.net>
 <20160823200941.GB2356@ZenIV.linux.org.uk>
 <1471984445.3746.129.camel@perches.com>
 <20160823204933.GA14311@csclub.uwaterloo.ca>
 <20160823212545.GC2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        ben@decadent.org.uk, luis.henriques@canonical.com,
        avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160823212545.GC2356@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2016 at 10:25:45PM +0100, Al Viro wrote:
> Sadly, sizeof is what we use when copying that sucker to userland.  So these
> padding bits in the end would've leaked, true enough, and the case is somewhat
> weaker.  And any normal architecture will have those, but then any such
> architecture will have no more trouble zeroing a 32bit value than 16bit one.

Hmm, good point.  Too bad I don't see a compiler option of "zero all
padding in structs".  Certainly generating the code should not really
be that different.

I see someone did request it 2 years ago:
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63479

-- 
Len Sorensen
