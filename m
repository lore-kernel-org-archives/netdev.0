From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-11-11
Date: Wed, 11 Nov 2009 11:20:31 -0800 (PST)
Message-ID: <20091111.112031.184370997.davem@davemloft.net>
References: <20091111172255.GH4392@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758611AbZKKTUG@vger.kernel.org>
In-Reply-To: <20091111172255.GH4392@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 11 Nov 2009 12:22:55 -0500

> Here is another batch of small fixes intended for 2.6.32.  Along with a
> number of simple fixes, there is also a MAINTAINERS update, some LED
> handling quirks for ath5k, a libertas beautification that is a prereq
> for a libertas fix, and an iwlwifi fix that was already sent for
> net-next-2.6 but which is needed to support an iwlwifi regression fix.
> 
> My personal favorite is the ath5k mcast filtering fix.  The problem
> only revealed itself when using IP autoconf w/ multicast DNS... :-)
> 
> Please let me know if there are problems!

Pulled, but that libertas "coding style cleanup" really pushes
the edge of what I'm willing to take into net-2.6 right now.

And I don't want to hear anything about how it "makes the bug fix
change simpler".  That absolutely doesn't apply when we're this deep
in -rc territory.

> P.S.  Due to the aformentioned iwlwifi fix, this will cause -next
> conflicts for sfr.  You may want to pull net-2.6 into net-next-2.6 after
> pulling this.  The iwlwifi conflicts can be resolved by taking the bigger
> hunks...

Yep, I noticed this, I'll sort it out, thanks.
