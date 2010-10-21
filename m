From: Florian Westphal <fw@strlen.de>
Subject: Re: [BUG] problems with "ip xfrm" on 32-bit userspace with 64-bit
 kernel
Date: Thu, 21 Oct 2010 09:50:56 +0200
Message-ID: <20101021075056.GE15247@Chamillionaire.breakpoint.cc>
References: <4CBF78B6.90002@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CBF78B6.90002@genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen <chris.friesen@genband.com> wrote:
> We've run into a 32/64 compatibility problem with iproute2.  The "ip
> xfrm monitor acquire" command doesn't work properly due to struct size
> mismatches between kernel and userspace.

Yes.  See archives for 'xfrm: add x86 CONFIG_COMPAT support'
(http://marc.info/?t=127050655600003&r=1&w=2)

for a discussion on why the patch set to fix this was rejected.
