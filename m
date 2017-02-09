From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] devlink: small cleanup around eswitch [sg]et
Date: Thu,  9 Feb 2017 15:54:32 +0100
Message-ID: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35260 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdBIO41 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:56:27 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so12205501wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:54:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Contains small devlink cleanup around eswitch get/set commands.

Jiri Pirko (4):
  devlink: fix the name of eswitch commands
  devlink: rename devlink_eswitch_fill to devlink_nl_eswitch_fill
  devlink: use nla_put_failure goto label instead of out
  devlink: allow to fillup eswitch attrs even if mode_get op does not
    exist

 include/uapi/linux/devlink.h | 10 +++++++--
 net/core/devlink.c           | 50 +++++++++++++++++++++++---------------------
 2 files changed, 34 insertions(+), 26 deletions(-)

-- 
2.7.4
