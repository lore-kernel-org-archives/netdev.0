From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [v3.8, v3.9] [Regression] brcmsmac: move PHY functions
Date: Mon, 1 Apr 2013 10:42:25 -0400
Message-ID: <20130401144225.GC21859@tuxdriver.com>
References: <5155F107.6050408@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: phaber@broadcom.com, arend@broadcom.com, pieterpg@broadcom.com,
	meuleman@broadcom.com, LKML <linux-kernel@vger.kernel.org>,
	brudley@broadcom.com, frankyl@broadcom.com,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5155F107.6050408@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 29, 2013 at 03:52:39PM -0400, Joseph Salisbury wrote:
> Hi Piotr,
> 
> A bug was opened against the Ubuntu kernel[0].  After a kernel
> bisect, it was found that reverting the following commit resolved
> this bug:
> 
> commit b83576341664957978e125f5f5db2f15496980b1
> Author: Piotr Haber <phaber@broadcom.com>
> Date:   Wed Nov 28 21:44:09 2012 +0100
> 
>     brcmsmac: move PHY functions
> 
> The regression was introduced as of v3.8-rc1.  The regression still
> exists in v3.9-rc4.
> 
> I see that you are the author of this patch, so I wanted to run this
> by you.  I was thinking of requesting a revert for v3.9, but I
> wanted to get your feedback first.
> 
> 
> Thanks,
> 
> Joe
> 
> [0] http://pad.lv/1131914

I recently reverted b6fc28a1, which is the follow-on to that patch.
The revert is _not_ in 3.9-rc5.

Could you try reverting that patch instead?  Does that fix the issue
for you?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
