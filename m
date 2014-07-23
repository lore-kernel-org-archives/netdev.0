From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv2] skbedit: allow the user to specify bitmask for mark
Date: Wed, 23 Jul 2014 09:16:29 -0400
Message-ID: <53CFB5AD.9020005@mojatatu.com>
References: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	eric.dumazet@gmail.com, Antonio Quartulli <antonio@open-mesh.com>
To: Antonio Quartulli <antonio@meshcoding.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:52800 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756589AbaGWNRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 09:17:11 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so7774429wiv.11
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 06:17:08 -0700 (PDT)
In-Reply-To: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/14 04:03, Antonio Quartulli wrote:
> From: Antonio Quartulli <antonio@open-mesh.com>
>
> The user may want to use only some bits of the skb mark in
> his skbedit rules because the remaining part might be used by
> something else.
>
> Introduce the "mask" parameter to the skbedit actor in order
> to implement such functionality.
>
> When the mask is specified, only those bits selected by the
> latter are altered really changed by the actor, while the
> rest is left untouched.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> ---
>
> Jamal, I'm not adding your Signed-off because the patches has new part with
> respect to v1.
>


Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
