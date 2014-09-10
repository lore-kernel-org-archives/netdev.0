From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] net: enable GRO for IPIP and SIT
Date: Tue, 9 Sep 2014 21:04:27 -0700
Message-ID: <CA+mtBx_1VWkzU3EcyR=o45CWGevhGdiJiKH-z5Kc7qzqyNkC9Q@mail.gmail.com>
References: <1410286996-302-1-git-send-email-therbert@google.com>
	<20140909.202738.854167452821989542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:45019 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaIJEE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 00:04:27 -0400
Received: by mail-ie0-f182.google.com with SMTP id tr6so4402556ieb.41
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 21:04:27 -0700 (PDT)
In-Reply-To: <20140909.202738.854167452821989542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2014 at 8:27 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue,  9 Sep 2014 11:23:13 -0700
>
>> This patch sets populates the IPIP and SIT offload structures with
>> gro_receive and gro_complete functions. This enables use of GRO
>> for these. Also, fixed a problem in IPv6 where we were not properly
>> initializing flush_id.
>
> We're going to need to sort this out, because these functions are
> now static after Eric's patches to fix sparse warnings.
>
> You're going to have to respin this with that patch you intended
> to add from the previous series that exported these routines.

I might be missing something, but I believe the functions referred in
this patch series were already static.
