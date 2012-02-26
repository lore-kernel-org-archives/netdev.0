From: David Miller <davem@davemloft.net>
Subject: Re: RFC: memory leak in udp_table_init
Date: Sun, 26 Feb 2012 14:20:38 -0500 (EST)
Message-ID: <20120226.142038.556939530554716833.davem@davemloft.net>
References: <4F48318E.8070902@am.sony.com>
	<CAP=VYLp7+Apubm=PHRLSw50V9zBKmV-xFRvcO4-qAogJVp7jcw@mail.gmail.com>
	<1330147182.2462.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, tim.bird@am.sony.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330147182.2462.25.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 25 Feb 2012 06:19:42 +0100

> [PATCH] mm: add a low limit to alloc_large_system_hash

I think you should just use zero as the default minimum for all
call sites except this UDP case we are trying to fix.

For example I see you used 16 for kernel/pid.c

Let's not try to do unrelated changes like that now, we can do such
tweaks later.
