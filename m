From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] Prepare the tree for un-inlined jhash.
Date: Thu, 25 Nov 2010 14:39:49 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011251439160.21752@obet.zrqbmnf.qr>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu> <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-11-25 14:15, Jozsef Kadlecsik wrote:

>jhash is widely used in the kernel and because the functions
>are inlined, the cost in size is significant. Also, the new jhash
>functions are slightly larger than the previous ones so better un-inline.
>As a preparation step, the calls to the internal macros are replaced
>with the plain jhash function calls.

Do you have a non-normative allyesconfig/allmodconfig build whose 
size(1) you can run on, to show approximately just how much it differs?


thanks,
Jan
