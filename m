From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] fou: avoid using sk_user_data before it is initialised
Date: Mon, 23 May 2016 14:05:17 -0700
Message-ID: <CAM_iQpXeoX_e2wi_gOMW_2VKMzAkEJ-J37tLZfsaDGwmiut7QA@mail.gmail.com>
References: <1463723837-9098-1-git-send-email-simon.horman@netronome.com> <20160523.135951.575984351254086980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:34421 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbcEWVFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 17:05:37 -0400
Received: by mail-yw0-f180.google.com with SMTP id c127so66371045ywb.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 14:05:37 -0700 (PDT)
In-Reply-To: <20160523.135951.575984351254086980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2016 at 1:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Fri, 20 May 2016 14:57:17 +0900
>
>> During initialisation sk->sk_user_data should not be used before
>> it is initialised.
>>
>> Found by bisection after noticing the following:
>  ...
>> Fixes: d92283e338f6 ("fou: change to use UDP socket GRO")
>> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>> ---
>> v2
>> * Updated implementation to simply access fou->protocol directly
>>   as suggested by Tom Herbert and Cong Want
>
> I think this was resolved in another way meanwhile.  If a fix is still
> needed, please respin.

This fix is only needed for -stable to backport, because Tom's
fix is within a series of patches, which makes it hard to backport.
