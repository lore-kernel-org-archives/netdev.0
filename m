From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/3] mlxsw: spectrum: Reduce number of supported
 802.1D bridges
Date: Wed, 18 May 2016 14:40:50 +0200
Message-ID: <20160518124050.GA3889@nanopsycho.orion>
References: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
 <1459844404-4698-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	corbet@lwn.net, sfeldma@gmail.com, nicolas.dichtel@6wind.com,
	vivien.didelot@savoirfairelinux.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33127 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbcERMkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 08:40:53 -0400
Received: by mail-wm0-f65.google.com with SMTP id r12so12573280wme.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 05:40:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459844404-4698-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 05, 2016 at 10:20:02AM CEST, jiri@resnulli.us wrote:
>From: Ido Schimmel <idosch@mellanox.com>
>
>Resources allocated for these bridges at init time cannot be later used
>for other purposes. While current number is supported by the device,
>it's mostly theoretical with regards to any real use case, which leads
>to poor utilization of device's resources. Solve that by reducing the
>number.
>
>The long term plan is to make this value (along with others) user
>configurable via devlink and write it to NVRAM, so that it can be used
>during the next init. Until then we must hardcode such values.
>
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Hi Dave.

This patch, commit b555cf4a50c17a9714715a2d7c8574dca1a7b356 ("mlxsw: spectrum:
Reduce number of supported 802.1D bridges") reduced the resources the
device allocates during init. Newer firmware versions now force a hard
limit on these resources and thus require this patch.

We would like to ask this commit be backported to stable kernels, so
that they can be used with newer firmware versions.

Thanks!

Jiri
