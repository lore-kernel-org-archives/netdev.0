From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC] make kmemleak scan __ro_after_init section (was: Re:
 [PATCH 0/5] genetlink improvements)
Date: Thu, 3 Nov 2016 14:49:36 -0600
Message-ID: <20161103204936.xntik7gkybxg34np@localhost>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
 <20161101172840.6d7d6278@jkicinski-Precision-T1700>
 <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
 <20161101185630.3c7d326f@jkicinski-Precision-T1700>
 <CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
 <20161102234755.4381f528@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20161102234755.4381f528@jkicinski-Precision-T1700>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2016 at 11:47:55PM +0000, Jakub Kicinski wrote:
> I realized that kmemleak is not scanning the __ro_after_init section...
> Following patch solves the false positives but I wonder if it's the
> right/acceptable solution.

Thanks for putting this together. I actually hit a similar issue on
arm64 but didn't get the chance to fix it (also at LPC). With a proper
commit message, feel free to add:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
