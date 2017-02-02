From: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal@milecki.pl>
Subject: Re: [PATCH 1/2] net: ethernet: bgmac: init sequence bug
Date: Thu, 02 Feb 2017 21:15:51 +0100
Message-ID: <efd17b6863565d63b37b1bf75082d7b9@milecki.pl>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-2-git-send-email-jon.mason@broadcom.com>
 <12ceba49-5465-072c-1770-b57d265bee86@milecki.pl>
 <CAMER8-WtBTR74YYfTkZWjrPQjdJ6ykaTPntGeB0Oor5rDnYJfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Zac Schroff <zschroff@broadcom.com>
To: Zac Schroff <zachary.schroff@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 19.mo6.mail-out.ovh.net ([188.165.56.177]:33207 "EHLO
        19.mo6.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751720AbdBBXxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:53:15 -0500
Received: from player787.ha.ovh.net (b9.ovh.net [213.186.33.59])
        by mo6.mail-out.ovh.net (Postfix) with ESMTP id 218A7A6FB8
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 21:15:58 +0100 (CET)
In-Reply-To: <CAMER8-WtBTR74YYfTkZWjrPQjdJ6ykaTPntGeB0Oor5rDnYJfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-02-02 01:31, Zac Schroff wrote:
> How about BCMA_IOCTL_PRESERVE_ACROSS_INIT?

I think wireless drivers may still set some these bits during init.

I've a simpler idea: make it bgmac specific. Call it sth like
BGMAC_BCMA_IOCTL_PRESERVE
BGMAC_BCMA_IOCTL_RESERVED
BGMAC_BCMA_IOCTL_DONT_TOUCH
