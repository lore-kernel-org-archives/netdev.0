From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] crash in 8139cp with 3.9.2 and KVM
Date: Thu, 16 May 2013 22:17:28 -0700
Message-ID: <1368767848.3301.75.camel@edumazet-glaptop>
References: <20130516214913.53ed65f9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:47002 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab3EQFRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 01:17:30 -0400
Received: by mail-da0-f50.google.com with SMTP id i23so1248891dad.37
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 22:17:30 -0700 (PDT)
In-Reply-To: <20130516214913.53ed65f9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 21:49 -0700, Stephen Hemminger wrote:
> Seeing the following panic when using emulated 8139cp with KVM and 3.9.2 kernel.
> 
> Looks like netdev_alloc_skb_ip_align() can return a fragmented skb sometimes
> and using skb_put() on a non-linear skb causes a panic.

Absolutely not, netdev_alloc_skb_ip_align() always provide a linear skb.
