From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 0/4] arp: always override existing neigh entries with
 gratuitous ARP
Date: Tue, 23 May 2017 22:56:31 +0200
Message-ID: <CAK8P3a162_RdXHLCPzg47+F7yadRGMDgFG_z5R6v65-heY1KAw@mail.gmail.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, ja@ssi.bg,
        Networking <netdev@vger.kernel.org>
To: Ihar Hrachyshka <ihrachys@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35433 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032799AbdEWU4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 16:56:32 -0400
Received: by mail-oi0-f67.google.com with SMTP id m17so29705249oik.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 13:56:32 -0700 (PDT)
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 9:41 PM, Ihar Hrachyshka <ihrachys@redhat.com> wrote:
> This patchset is spurred by discussion started at
> https://patchwork.ozlabs.org/patch/760372/ where we figured that there is no
> real reason for enforcing override by gratuitous ARP packets only when
> arp_accept is 1. Same should happen when it's 0 (the default value).
>
> changelog v2: handled review comments by Julian Anastasov
> - fixed a mistake in a comment;
> - postponed addr_type calculation to as late as possible.

This seems to have caused a build warning:

net/ipv4/arp.c:880:35: warning: 'addr_type' may be used uninitialized
in this function [-Wmaybe-uninitialized]

       Arnd
