From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: [2.6 patch] net/wanrouter/wanmain.c: cleanups
Date: Thu, 11 Jan 2007 17:57:50 +0300
Message-ID: <b6fcc0a0701110657j585aaf1fl599eb3c548ea7eb6@mail.gmail.com>
References: <20070111134938.GH20027@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:7450 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030241AbXAKO5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 09:57:52 -0500
Received: by nf-out-0910.google.com with SMTP id o25so922214nfa
        for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 06:57:50 -0800 (PST)
To: "Adrian Bunk" <bunk@stusta.de>
In-Reply-To: <20070111134938.GH20027@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/11/07, Adrian Bunk <bunk@stusta.de> wrote:
> This patch contains the following cleanups:
> - make the following needlessly global functions static:
>   - lock_adapter_irq()
>   - unlock_adapter_irq()

These are 1:1 wrappers around spinlock_irqsave/restore. Just remove them.
