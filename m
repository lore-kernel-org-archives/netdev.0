From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] skbedit: allow the user to specify bitmask for mark
Date: Mon, 21 Jul 2014 06:43:00 -0400
Message-ID: <53CCEEB4.80005@mojatatu.com>
References: <1405931720-24383-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Antonio Quartulli <antonio@open-mesh.com>
To: Antonio Quartulli <antonio@meshcoding.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38987 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbaGUKnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 06:43:12 -0400
Received: by mail-ig0-f182.google.com with SMTP id c1so2658209igq.9
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 03:43:12 -0700 (PDT)
In-Reply-To: <1405931720-24383-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/14 04:35, Antonio Quartulli wrote:
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

Looks good!

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
