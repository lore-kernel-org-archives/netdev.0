From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.18 BUG: unable to handle kernel NULL pointer dereference at virtual address 000,0000a
Date: Sun, 24 Sep 2006 19:59:34 +0200
Message-ID: <20060924175934.GA15420@elte.hu>
References: <45155915.7080107@cweiske.de> <20060923134244.e7b73826.akpm@osdl.org> <45164BA6.60200@cweiske.de> <20060924031923.76886810.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Weiske <cweiske@cweiske.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, reiserfs-dev@namesys.com,
	Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752023AbWIXSHV@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060924031923.76886810.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@osdl.org> wrote:

> You have tcp_v6 lockdep warnings.  They're in
> http://xml.cweiske.de/dojo%20kernelpanic%20+%20debug.tar.bz2 is anyone is
> keen.  (I've largely lost interest in lockdep warnings - many of them are
> false positives and require make-lockdep-shut-up patches).

FYI, this is from Herbert Xu's recent mail to netdev:

| Subject: Re: neigh_lookup lockdep warning
|
| [...]
| BTW, out of the last four validator reports I've read three have 
| turned out to be genuine bugs.  So you guys have done a fantastic job!
