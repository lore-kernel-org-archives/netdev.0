From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/4] ps3_gelic: lower NAPI weight
Date: Wed, 21 Aug 2013 22:17:07 +0400
Message-ID: <52150423.9050900@cogentembedded.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com> <1377103771-1590-4-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Geoff Levand <geoff@infradead.org>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60759 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab3HUSRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 14:17:02 -0400
Received: by mail-lb0-f174.google.com with SMTP id w20so882050lbh.33
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 11:17:00 -0700 (PDT)
In-Reply-To: <1377103771-1590-4-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2013 08:49 PM, Michal Schmidt wrote:

> Since commit 82dc3c63 netif_napi_add() produces an error message if

    Likewise, need a summary line.

> a NAPI poll weight greater than 64 is requested.

> GELIC_NET_NAPI_WEIGHT is defined to GELIC_NET_RX_DESCRIPTORS,
> which is 128.

> Use the standard NAPI weight.

> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Geoff Levand <geoff@infradead.org>

WBR, Sergei
