From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH 0/7] Adding permanent config get/set to devlink
Date: Tue, 17 Oct 2017 18:58:31 -0400
Message-ID: <CA+Jmh7ECVdB87fTbiByMjCgyU7JgmaDbe52HSz2QM2ft2-0EFQ@mail.gmail.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>,
        Steven Lin <steven.lin1@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:46921 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753624AbdJQW6x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 18:58:53 -0400
Received: by mail-qk0-f177.google.com with SMTP id k123so4132153qke.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 15:58:52 -0700 (PDT)
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My apologies - this patchset was intended for net-next; I forgot to
add that to the subject line, though.

Steve

On Tue, Oct 17, 2017 at 4:44 PM, Steve Lin <steven.lin1@broadcom.com> wrote:
> DIFFERENCES FROM RFC:
> Implemented most of the changes suggested by Jiri and others.
> Thanks for the valuable feedback!
>
> Adds a devlink command for getting & setting permanent
> (persistent / NVRAM) device configuration parameters, and
> enumerates the parameters as nested devlink attributes.
>
> bnxt driver patches make use of these new devlink cmds/
> attributes.
>
> Steve Lin (7):
>   devlink: Add permanent config parameter get/set operations
>   devlink: Adding NPAR permanent config parameters
>   devlink: Adding high level dev perm config params
>   devlink: Adding perm config of link settings
>   devlink: Adding pre-boot permanent config parameters
>   bnxt: Move generic devlink code to new file
>   bnxt: Add devlink support for config get/set
>
>  drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   1 +
>  drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 363 ++++++++++++++++++++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  56 ++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 ++++++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     |  53 +---
>  drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h     |  37 +--
>  include/net/devlink.h                             |   4 +
>  include/uapi/linux/devlink.h                      | 113 +++++++
>  net/core/devlink.c                                | 300 ++++++++++++++++++
>  10 files changed, 944 insertions(+), 85 deletions(-)
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
>  create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h
>
> --
> 2.7.4
>
