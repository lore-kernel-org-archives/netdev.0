From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 net] ravb: clear RIC1 in init instead of stop
Date: Mon, 14 Dec 2015 19:57:39 +0300
Message-ID: <566EF503.10304@cogentembedded.com>
References: <1450110298-21392-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35588 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbbLNQ5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 11:57:42 -0500
Received: by lbpu9 with SMTP id u9so103631181lbp.2
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 08:57:41 -0800 (PST)
In-Reply-To: <1450110298-21392-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2015 07:24 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> AVB-DMAC Receive FIFO Warning interrupt is not enabled, so it is not
> necessary to disable the interrupt in ravb_close().
> On the other hand, this patch disables the interrupt in ravb_dmac_init() to
> prevent the possibility that the interrupt is issued by the state that
> a boot loader left.
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
>
> This patch is based on the master branch of David Miller's networking
> tree.

    I think this should rather go into net-next.git though...

MBR, Sergei
