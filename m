From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH ethtool 0/5] RSS improvements + new speeds
Date: Thu, 19 Mar 2015 16:17:05 +0200
Message-ID: <CAJ3xEMiREq3yXerALESc9NNT1YCAjsU6GX+fm5-SRpfB2hTJHg@mail.gmail.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33676 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbbCSORG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 10:17:06 -0400
Received: by obcxo2 with SMTP id xo2so55386339obc.0
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 07:17:05 -0700 (PDT)
In-Reply-To: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 25, 2015 at 3:51 PM, Amir Vadai <amirv@mellanox.com> wrote:
> Hi Ben,
>
> This patchset contains some features and small bug fixes.
> A patch by Eyal Perry to enable setting RSS hash function, kernel support was
> added in commit 892311f ("ethtool: Support for configurable RSS hash
> function").
> Eyal Grossman added some missing advertised speeds and fixed some issues in
> this area of code.

Ben, Amir, where this series stands?

>
> Patches were tested and applied on top of commit 4614098 ("Release version 3.16.")
>
> Thanks,
> Amir
>
> Eyal Grossman (3):
>   ethtool-copy.h: sync with net
>   ethtool: Add missing Advertised speeds
>   ethtool: Return bad status when send_ioctl fails
>
> Eyal Perry (2):
>   ethtool: Prettify RX flow hash indirection table print
>   ethtool: Support for configurable RSS hash function
>
>  ethtool-copy.h |  67 +++++++++++++++++++++++++++----
>  ethtool.8.in   |   7 ++++
>  ethtool.c      | 122 ++++++++++++++++++++++++++++++++++++++++-----------------
>  3 files changed, 152 insertions(+), 44 deletions(-)
>
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
