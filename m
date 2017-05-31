From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] netlink: include netnsid only when netns
 differs.
Date: Wed, 31 May 2017 10:38:21 +0200
Message-ID: <1b83c01b-8fe3-8e9b-cae7-4064527c1c21@6wind.com>
References: <20170530213325.21652-1-fbl@sysclose.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Flavio Leitner <fbl@sysclose.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35989 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdEaIi0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 04:38:26 -0400
Received: by mail-wm0-f48.google.com with SMTP id 7so110381175wmo.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 01:38:25 -0700 (PDT)
In-Reply-To: <20170530213325.21652-1-fbl@sysclose.org>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/05/2017 à 23:33, Flavio Leitner a écrit :
> Don't include netns id for notifications broadcasts when the
> socket and the skb are in the same netns because it will be
> an error which can't be distinguished from a peer netns failing
> to allocate an id.
I don't understand the problem. peernet2id() doesn't allocate ids, it only do a
lookup. If you need an id for the current netns, you have to allocate one.

This patch changes the metadata exported to the userland and will break existing
tools.
