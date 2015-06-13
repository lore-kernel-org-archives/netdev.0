From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: gaurd against NULL rocker_port when
 removing ports
Date: Sat, 13 Jun 2015 11:07:51 +0200
Message-ID: <20150613090751.GA2016@nanopsycho.orion>
References: <1434168584-61990-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34529 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbFMJHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 05:07:54 -0400
Received: by wibut5 with SMTP id ut5so35103228wib.1
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 02:07:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434168584-61990-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jun 13, 2015 at 06:09:44AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>The ports array is filled in as ports are probed, but if probing doesn't
>finish, we need to stop only those ports that where probed successfully.
>Check the ports array for NULL to skip un-probed ports when stopping.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
