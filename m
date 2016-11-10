From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: tcp response should set oif only if it is L3 master
Date: Thu, 10 Nov 2016 10:40:00 +0900
Message-ID: <CAKD1Yr2nt9v0B2oPyt_sW9bcax2G13LgkwDDf5pxvjxa+n5HRg@mail.gmail.com>
References: <1478711246-17440-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35326 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753032AbcKJBkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 20:40:22 -0500
Received: by mail-it0-f52.google.com with SMTP id e187so237340063itc.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 17:40:21 -0800 (PST)
In-Reply-To: <1478711246-17440-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 2:07 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Revert the change to ip_send_unicast_reply and tcp_v6_send_response such
> that the oif in the flow is set to the skb_iif only if skb_iif is an L3
> master.

This fixes the IPv4 and IPv6 tests, thanks!

Tested-by: Lorenzo Colitti <lorenzo@google.com>
Acked-by: Lorenzo Colitti <lorenzo@google.com>
