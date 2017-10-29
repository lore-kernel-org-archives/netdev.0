From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 11/14] bnxt_en: add support for Flower based
 vxlan encap/decap offload
Date: Sun, 29 Oct 2017 13:15:10 -0700
Message-ID: <CACKFLi=-yjoY4m+rKOnyxL6TbgLptMeeipMZNAmoWF9zTp1+mA@mail.gmail.com>
References: <1509033092-1887-12-git-send-email-michael.chan@broadcom.com> <201710300233.CId6BGMS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Sathya Perla <sathya.perla@broadcom.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:53441 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752046AbdJ2UPM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 16:15:12 -0400
Received: by mail-oi0-f51.google.com with SMTP id h6so18202901oia.10
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2017 13:15:11 -0700 (PDT)
In-Reply-To: <201710300233.CId6BGMS%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 29, 2017 at 11:22 AM, kbuild test robot <lkp@intel.com> wrote:

> All warnings (new ones prefixed by >>):
>
>    drivers/net//ethernet/broadcom/bnxt/bnxt_tc.c: In function 'bnxt_tc_resolve_tunnel_hdrs':
>    drivers/net//ethernet/broadcom/bnxt/bnxt_tc.c:882:10: error: implicit declaration of function 'vlan_dev_priv' [-Werror=implicit-function-declaration]
>       struct vlan_dev_priv *vlan = vlan_dev_priv(dst_dev);
>              ^
>

This has already been fixed by this commit:

952c5719aac6587f1e0add97dca79f9e73887f9b
bnxt_en: Fix randconfig build errors.
