From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: kernel BUG at /usr/src/linux-2.6.25/kernel/workqueue.c:224!
	(r8169?)
Date: Mon, 21 Apr 2008 23:29:23 +0200
Message-ID: <20080421212923.GB2931@electric-eye.fr.zoreil.com>
References: <76366b180804201548g309ae6cci286ed6552f3cb71e@mail.gmail.com> <76366b180804202016l19ac362cyb814781449f81e9a@mail.gmail.com> <20080421203458.GA2931@electric-eye.fr.zoreil.com> <76366b180804211422k33057607p586b5deed7849c07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45676 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752814AbYDUVrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:47:32 -0400
Content-Disposition: inline
In-Reply-To: <76366b180804211422k33057607p586b5deed7849c07@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Paprocki <andrew@ishiboo.com> :
[...]
> On this kernel CONFIG_R8169_NAPI is disabled, so that code would not
> even be compiled in. Is NAPI stable enough that I should be using it
> now ?

Yes.

> (It is still marked experimental)

I'll remove the non-NAPI code. It's long overdue.

-- 
Ueimor
