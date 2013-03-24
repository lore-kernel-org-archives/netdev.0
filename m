From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bridge: avoid br_ifinfo_notify when nothing
 changed
Date: Sun, 24 Mar 2013 17:34:47 +0300
Message-ID: <514F0F07.9050702@cogentembedded.com>
References: <1364015653-7322-1-git-send-email-honkiko@gmail.com> <1364131607-11698-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.hengli.com.au, zhiguo.hong@emc.com
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:57441 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab3CXNdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 09:33:24 -0400
Received: by mail-la0-f51.google.com with SMTP id fo13so9884654lab.10
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 06:33:22 -0700 (PDT)
In-Reply-To: <1364131607-11698-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/24/2013 04:26 PM, Hong Zhiguo wrote:

> When neither IFF_BRIDGE nor IFF_BRIDGE_PORT is set,
> and afspec == NULL but  protinfo != NULL, we run into
> "if (err == 0) br_ifinfo_notify(RTM_NEWLINK, p);" with
> random value in ret.
>
> Thanks to Sergei for pointing out the error in commit comments.
>
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

     For the future, if you post the revised version of the patch, you
should indicate in the subject it like this: [PATCH v2].

WBR, Sergei
