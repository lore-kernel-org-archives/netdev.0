From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net 0/3] bnxt_en: Phy related fixes.
Date: Fri, 19 Feb 2016 22:08:32 -0800
Message-ID: <CACKFLi=4b6G=Na9GCNivwZZLJ-pOCjKSPupyRQ4bnbzriCKRkA@mail.gmail.com>
References: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
	<20160219.234007.59680380627387701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34439 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbcBTGId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 01:08:33 -0500
Received: by mail-oi0-f51.google.com with SMTP id m82so26147181oif.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 22:08:32 -0800 (PST)
In-Reply-To: <20160219.234007.59680380627387701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 8:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Fri, 19 Feb 2016 19:43:18 -0500
>
>> 3 small patches to fix PHY related code.
>
> Series applied, thanks Michael.
>
> Although I'm not so sure how wise it is to not fail an ->open()
> if the PHY settings fail.....

The firmware will still have default settings for the PHY.  More importantly,
for the VF, the call doesn't do anything real and we should allow the VF to
proceed if the call fails.  Thanks.
