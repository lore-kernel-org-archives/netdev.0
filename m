From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/4] ip: Allow to easy change network namespace
Date: Wed, 24 Dec 2014 12:35:22 -0800
Message-ID: <20141224123522.15370a16@urahara>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
	<1418493334-23142-3-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35515 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbaLXUfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:35:31 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so10591024pab.28
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:35:30 -0800 (PST)
In-Reply-To: <1418493334-23142-3-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Dec 2014 19:55:32 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added new '-netns' option to simplify executing following cmd:
> 
>     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> 
>     to
> 
>     ip -n[etns] NETNS OPTIONS COMMAND OBJECT
> 
> e.g.:
> 
>     ip -net vnet0 link add br0 type bridge
>     ip -n vnet0 link
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Needs to be rebased against current upstream code.
Will not apply clean any more.

Please resubmit whole patch series.
