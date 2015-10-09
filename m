From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Fri, 9 Oct 2015 06:28:22 +0200
Message-ID: <20151009042822.GC2161@nanopsycho.orion>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34631 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757043AbbJIE2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:28:24 -0400
Received: by wicfx3 with SMTP id fx3so53778042wic.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 21:28:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444357400-37078-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 09, 2015 at 04:23:19AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
>support setting ageing_time (or setting bridge attrs in general).
>
>If push fails, don't update ageing_time in bridge and return err to user.
>
>If push succeeds, update ageing_time in bridge and run gc_timer now to
>recalabrate when to run gc_timer next, based on new ageing_time.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Jiri Pirko <jiri@mellanox.com>
>
