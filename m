From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ping: make ping_v6_sendmsg static
Date: Wed, 23 Mar 2016 14:53:10 +0300
Message-ID: <56F283A6.6020801@cogentembedded.com>
References: <1458727191-36958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36599 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbcCWLxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 07:53:17 -0400
Received: by mail-lb0-f182.google.com with SMTP id qe11so7958919lbc.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 04:53:16 -0700 (PDT)
In-Reply-To: <1458727191-36958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/23/2016 12:59 PM, Haishuang Yan wrote:

> As ping_v6_sendmsg is used only in this file,
> making it static
>
> The body of "pingv6_prot" and "pingv6_protosw" were
> moved at the middle of the file, to avoid having to
> declare some static prototypes.
>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

    These seem as 2 independent changes, so should be in 2 separate patches.

[...]

MBR, Sergei
