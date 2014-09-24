From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH 03/24] net: rbridge: Add RBridge structure
Date: Wed, 24 Sep 2014 10:18:11 -0700
Message-ID: <CAHA+R7O5Re3Q0LeE-nXKY4wgH5_39WDWn++ZcDkJUjJtsP-NXA@mail.gmail.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
	<1411573940-14079-4-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, william@gandi.net,
	f.cachereul@alphalink.fr, Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:38100 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIXRSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:18:13 -0400
Received: by mail-lb0-f181.google.com with SMTP id b6so5992603lbj.12
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 10:18:12 -0700 (PDT)
In-Reply-To: <1411573940-14079-4-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 8:51 AM, Ahmed Amamou <ahmed@gandi.net> wrote:
> add basic RBridge structure
> add basic TRILL constant
> define rbr_nickinfo structure which represent distant RBridge information
>
> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> ---
>  net/bridge/rbridge/rbr_private.h | 60 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 60 insertions(+)
>  create mode 100644 net/bridge/rbridge/rbr_private.h

Do you really need to create net/bridge/rbridge/ for the code?
Using rbr_* prefix seems enough for me since they anyway
share some code elsewhere.
