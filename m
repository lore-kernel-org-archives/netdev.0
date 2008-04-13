From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Sun, 13 Apr 2008 11:36:58 -0500
Message-ID: <20080413163658.GC7010@sergelap.austin.ibm.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp> <20080409131151.GK11962@parisc-linux.org> <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp> <20080411143013.GB11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	crispin@crispincowan.com
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080411143013.GB11962@parisc-linux.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Matthew Wilcox (matthew@wil.cx):
> On Fri, Apr 11, 2008 at 11:12:27PM +0900, Tetsuo Handa wrote:
> > Matthew Wilcox wrote:
> > > When the rule is put in place, say "No modifications to /etc/passwd",
> > > look up the inode and major:minor of /etc/passwd.  If there's a rename,
> > > look up the new inode number.  If it's mounted elsewhere, it doesn't
> > > matter, they still can't modify it because it has the same
> > > major:minor:inode.
> > 
> > If write access is denied because of a rule "No modifications to /etc/passwd",
> > a rule "Allow modifications to /tmp/passwd" can no longer be enforced after
> > "mount --bind /etc/ /tmp/" or "mount --bind /etc/passwd /tmp/passwd" or
> > "mv /etc/passwd /tmp/passwd" or "ln /etc/passwd /tmp/passwd" is done.
> 
> That's a fundamental limitation of pathname-based security though.
> If the same file exists in two places, you have to resolve the question
> of which rule overrides the other.

In the past, Crispin has given clear, concise explanations of a few of
the things pathname based access control in fact excels at.  Crispin,
can you recite those again so we can think constructively about which
(if any) of the currently considered options are or are not sufficient?

I.e. what would be a motivation for a rule like 'no modifications to
/etc/passwd', and what precisely would and would not be accepted ways to
get around it (and why)?

thanks,
-serge
