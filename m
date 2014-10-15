From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 11:33:23 +0200
Message-ID: <20141015113323.5321b2f7@uryu.home.lan>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jkosina@suse.cz>, <netdev@vger.kernel.org>,
	<LeoLi@freescale.com>, <linux-doc@vger.kernel.org>
To: Pan Jiafei <Jiafei.Pan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:61603 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbaJOJdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 05:33:42 -0400
Received: by mail-wi0-f176.google.com with SMTP id hi2so12402527wib.3
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 02:33:41 -0700 (PDT)
In-Reply-To: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since an skb can sit forever in an application queue, you have created
an easy way to livelock the system when enough skb's are waiting to be
read.
