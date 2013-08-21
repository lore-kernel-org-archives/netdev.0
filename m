From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/4] jme: lower NAPI weight
Date: Wed, 21 Aug 2013 22:15:18 +0400
Message-ID: <521503B6.4010105@cogentembedded.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com> <1377103771-1590-2-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:47383 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab3HUSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 14:15:12 -0400
Received: by mail-la0-f54.google.com with SMTP id ea20so642546lab.27
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 11:15:11 -0700 (PDT)
In-Reply-To: <1377103771-1590-2-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/21/2013 08:49 PM, Michal Schmidt wrote:

> Since commit 82dc3c63 netif_napi_add() produces an error message if

    Please also specify that commit's summary line in parens.

> a NAPI poll weight greater than 64 is requested.

> jme requests a quarter of the rx ring size as the NAPI weight.
> jme's rx ring size is 1 << 9 = 512.

> Use the standard NAPI weight.

> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Guo-Fu Tseng <cooldavid@cooldavid.org>

WBR, Sergei
