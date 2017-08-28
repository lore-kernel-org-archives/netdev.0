From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 6/6] mpls: VPLS support
Date: Mon, 28 Aug 2017 11:21:27 +0200
Message-ID: <025f7bf9-72d6-53c4-6680-4e20313aecf2@6wind.com>
References: <20170821171523.951260-1-equinox@diac24.net>
 <20170821171523.951260-7-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org
To: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:38369 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdH1JVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 05:21:38 -0400
Received: by mail-wr0-f182.google.com with SMTP id y14so8676260wrd.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 02:21:37 -0700 (PDT)
In-Reply-To: <20170821171523.951260-7-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

any opinion on vpls driver path ?

On 08/21/2017 07:15 PM, David Lamparter wrote:
> [work-in-progress, works but needs changes]
> [v2: refactored lots of things, e.g. dst_metadata, no more genetlink]
> [v4: removed pointless include/net/vpls.h, squashed pseudowire control
> word support, squashed netlink lwtunnel access bits]
>
> Signed-off-by: David Lamparter <equinox@diac24.net>
> ---
>  include/net/dst_metadata.h    |  24 ++
>  include/uapi/linux/lwtunnel.h |   8 +
>  net/core/lwtunnel.c           |   1 +
>  net/mpls/Kconfig              |  11 +
>  net/mpls/Makefile             |   1 +
>  net/mpls/vpls.c               | 550 ++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 595 insertions(+)
>  create mode 100644 net/mpls/vpls.c
