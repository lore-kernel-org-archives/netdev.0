From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH ipsec-next 6/8] xfrm: policy: only use rcu in
 xfrm_sk_policy_lookup
Date: Thu, 17 Nov 2016 09:55:51 +0100
Message-ID: <efbb4324-b407-bc77-518b-8d5988be5451@6wind.com>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
 <1470921479-25592-7-git-send-email-fw@strlen.de>
 <0e235471-cb63-2376-c42d-5872e78e4c98@6wind.com>
 <20161116173028.GI30581@breakpoint.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35876 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbcKQIzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 03:55:55 -0500
Received: by mail-wm0-f45.google.com with SMTP id g23so296230446wme.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 00:55:54 -0800 (PST)
In-Reply-To: <20161116173028.GI30581@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/11/2016 à 18:30, Florian Westphal a écrit :
[snip]
> This should fix it (if we succeed grabbing the refcount, then if (err && !xfrm_pol_hold_rcu
> evaluates to false and we hit last else branch and set pol to ERR_PTR(0)...
Haha, right :) Thank you for the quick fix.
The patch solves my problem. You can add my 'tested-by' tag in the formal
submission.

Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
