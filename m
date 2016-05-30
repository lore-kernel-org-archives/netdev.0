From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: Add ESF in RCR for enabling separation
 filter
Date: Mon, 30 May 2016 17:30:29 +0300
Message-ID: <ac6ed5e5-0adf-3147-2bd6-1752cf31d587@cogentembedded.com>
References: <1464553500-19043-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35862 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755059AbcE3Oad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 10:30:33 -0400
Received: by mail-lf0-f48.google.com with SMTP id b73so50754383lfb.3
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 07:30:33 -0700 (PDT)
In-Reply-To: <1464553500-19043-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2016 11:25 PM, Yoshihiro Kaneko wrote:

> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
>
> This patch adds enabling separation filter(ESF) is setting value of B'11.
> This setting filter for separating AVB stream frames from non-AVB stream
> frames is enabled. Non-matching frames from a stream are processed in
> queue 0(best effort). H/W manual recommends B'11 or B'10.
> When B'10 is setting, Non-mating frames are discarded.

    It was somewhat hard for me to parse that...

> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
