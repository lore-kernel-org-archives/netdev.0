From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.17 regression: Very slow net transfer from some hosts
Date: Tue, 11 Apr 2006 12:21:24 -0700
Message-ID: <20060411122124.55ab3b5c@localhost.localdomain>
References: <443C03E6.7080202@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751090AbWDKTVo@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <443C03E6.7080202@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Apr 2006 20:30:46 +0100
Daniel Drake <dsd@gentoo.org> wrote:

> Hi,
> 
> Since sometime after 2.6.16, some websites have been very slow to load. 
>   Examples include:
> 
> http://zd1211.ath.cx
> http://developer.osdl.org/shemminger/blog/
> http://www.reactivated.net/weblog
> 
> On a good kernel, "wget http://zd1211.ath.cx" says:
> 20:23:38 (90.44 KB/s) - `index.html' saved [20895/20895]
> 
> On a bad kernel:
> 20:14:18 (327.01 B/s) - `index.html' saved [20895/20895]
> 
> I reproduced this on two different internet connections (same ISP 
> though). However I cannot reproduce it on my other system.
> 
> git-bisect tracked it down to:
> 
> 7b4f4b5ebceab67ce440a61081a69f0265e17c2a is first bad commit
> diff-tree 7b4f4b5ebceab67ce440a61081a69f0265e17c2a (from 
> 2babf9daae4a3561f3264638a22ac7d0b14a6f52)
> Author: John Heffner <jheffner@psc.edu>
> Date:   Sat Mar 25 01:34:07 2006 -0800
> 
>      [TCP]: Set default max buffers from memory pool size
> 
> Indeed, reverting this patch from 2.6.17-rc1-git4 allows those sites to 
> load again.
> 
> Any ideas?

Get a tcpdump. There are tools to sanitize the file if you worry about
ip addresses, etc. 
