From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [PATCH v3 0/4] Introduce a new helper for parsing ipv[4|6]:port
 to socket address
Date: Mon, 13 Mar 2017 16:00:09 +0200
Message-ID: <55ad78fd-266f-09b9-417d-b6cf7b723879@grimberg.me>
References: <1489063793-12838-1-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-nvme@lists.infradead.org, netdev@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35048 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751359AbdCMOAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 10:00:14 -0400
Received: by mail-wr0-f193.google.com with SMTP id u108so20210619wrb.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 07:00:12 -0700 (PDT)
In-Reply-To: <1489063793-12838-1-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Changes from v1:
> - rebased to 4.11-rc1
> - improved changelogs
>
> Changes from v0:
> - rebased on 4.10
> - splitted inet_pton_with_scope to be a bit saner (from Chrsitoph)
> - converted nvme-rdma host_traddr to use a generic helper
>
> We have some places in the stack that support ipv4 and ipv6. In
> some cases the user configuration does not reveal which
> address family is given and needs to be parsed from the input string.
>
> Given that the user-input varies between subsystems, some processing
> is required from the call-site to separate address and port strings.
>
> As a side-effect, this set adds ipv6 support for nvme over fabrics.

Hi Dave,

This set got review tags from two kernel maintainers but this is your
realm so I wouldn't be comfortable moving forward with this without
your feedback.
