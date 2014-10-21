From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2][V2] xfrm6: fix a potential use after free in xfrm6_policy.c
Date: Tue, 21 Oct 2014 15:57:53 +0400
Message-ID: <54464A41.9050102@cogentembedded.com>
References: <1413851652-22553-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:40836 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181AbaJUL54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 07:57:56 -0400
Received: by mail-la0-f42.google.com with SMTP id gf13so977248lab.15
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 04:57:54 -0700 (PDT)
In-Reply-To: <1413851652-22553-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/21/2014 4:34 AM, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>

> pskb_may_pull() maybe change skb->data and make nh and exthdr pointer
> oboslete, so recompute the nd and exthdr

> V2: insert a space between date type(like __be16) and * as suggested by
> Sergei Shtylyov

    This passage should preferably go under the -- tear line.

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

    You should re-post the whole series anew.

WBR, Sergei
