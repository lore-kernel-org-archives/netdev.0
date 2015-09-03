From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 03 Sep 2015 10:40:32 -0700 (PDT)
Message-ID: <20150903.104032.767889134756094076.davem@davemloft.net>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	<CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo.bianconi83@gmail.com, johannes.berg@intel.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 3 Sep 2015 09:45:44 -0700

> But happily gcc has a really really valid warning (kudos - I often end
> up ragging on the bad warnings gcc has, but this one is a keeper),
> because a few lines down the mistake then turns into pure and utter
> garbage.

I really wish my GCC had emitted a warning for this, I'm on 4.9.2 here:

[davem@localhost linux]$ make net/mac80211/rate.o 
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CC [M]  net/mac80211/rate.o
[davem@localhost linux]$

Linus, what GCC version are you using and what does the warning look
like?

Anyways, Johannes please get this fixed, thanks.
