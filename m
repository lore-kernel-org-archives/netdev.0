From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFT/PATCH] 3c509: use proper suspend/resume API
Date: Wed, 15 Feb 2006 02:25:23 -0800
Message-ID: <20060215022523.1d21b9c9.akpm@osdl.org>
References: <1139935173.22151.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751048AbWBOK0h@vger.kernel.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1139935173.22151.2.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>
> I am looking for someone with 3c509 netword card that can do
>  suspend/resume to test this patch.

I have a 3c509, and I'm not afraid to use it!

Problem is, it doesn't resume correctly either with or without the patch:
it needs rmmod+modprobe to get it going again.  (Which is better than the
aic7xxx driver, which has a coronary and panics the kernel on post-resume
reboot).

But at least nothing got worse, and it makes that darn warning go away.
