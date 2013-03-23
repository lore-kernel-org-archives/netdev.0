From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bridge: avoid br_ifinfo_notify when nothing
 changed
Date: Sat, 23 Mar 2013 19:06:44 +0400
Message-ID: <514DC504.5060101@cogentembedded.com>
References: <1364015653-7322-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.hengli.com.au, zhiguo.hong@emc.com
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:46406 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058Ab3CWPHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 11:07:47 -0400
Received: by mail-la0-f46.google.com with SMTP id fq12so9041021lab.33
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 08:07:45 -0700 (PDT)
In-Reply-To: <1364015653-7322-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-03-2013 9:14, Hong Zhiguo wrote:

> When neither IFF_BRIDGE_PORT or IFF_BRIDGE_PORT is set,

    That is the same flag repeated twice.

> and afspec == NULL but  protinfo != NULL, we run into
> "if (err == 0) br_ifinfo_notify(RTM_NEWLINK, p);" with
> random value in ret.

> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

WBR, Sergei
