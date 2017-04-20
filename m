From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] mlxsw: spectrum_acl_tcam: Get tcam_region_info
 returned by FW on PTAR
Date: Thu, 20 Apr 2017 17:44:04 +0200
Message-ID: <20170420154404.GC19004@nanopsycho.orion>
References: <1492588470-1951-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36697 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970807AbdDTPoH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:44:07 -0400
Received: by mail-wm0-f67.google.com with SMTP id u65so3876865wmu.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:44:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492588470-1951-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 19, 2017 at 09:54:30AM CEST, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>During PTAR register access, FW processes tcam_region_info passed by
>driver and also returns modified tcam_region_info back. This needs to be
>stored by driver for any future calls.
>
>Fixes: 22a677661f56 ("mlxsw: spectrum: Introduce ACL core with simple TCAM implementation")
>Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
>Reviewed-by: Ido Schimmel <idosch@mellanox.com>

This is actually not needed. Please drop.
