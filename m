From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next 3/5] mlxsw: Move PCI id table definitions into
 driver modules
Date: Thu, 27 Oct 2016 16:39:23 +0200
Message-ID: <2df03fe8-8f7a-f6af-6894-54e07f61a962@redhat.com>
References: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
 <1477573981-26546-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38604 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942748AbcJ0Oj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 10:39:27 -0400
In-Reply-To: <1477573981-26546-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 27.10.2016 v 15:12 Jiri Pirko napsal(a):
> From: Jiri Pirko <jiri@mellanox.com>
>
> So far, mlxsw_pci.ko is the module that registers PCI table for all
> drivers (spectrum and switchx2). That is problematic for example with
> dracut. Since mlxsw_spectrum.ko and mlxsw_switchx2.ko are loaded
> dynamically from within mlxsw_core.ko, dracut does not have track of
> them and avoids them from being included in initramfs.
>
> So make this in an ordinary way and define the PCI tables in individual
> driver modules, so it can be properly loaded and included in dracut
> initramfs image. As a side effect, this patch could remove no longer
> necessary driver "kind" strings which were used to link PCI ids with
> individual mlxsw drivers.
>
> Suggested-by: Ivan Vecera <ivecera@redhat.com>
> Tested-by: Ivan Vecera <ivecera@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Thanks Jiri.

Acked-by: Ivan Vecera <ivecera@redhat.com>
