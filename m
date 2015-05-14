From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: fix a neigh entry leak issue
Date: Thu, 14 May 2015 10:44:06 +0200
Message-ID: <20150514084405.GB2197@nanopsycho.mtl.com>
References: <1431587190-28901-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33813 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620AbbENIoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 04:44:12 -0400
Received: by wguv19 with SMTP id v19so5652706wgu.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 01:44:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431587190-28901-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 14, 2015 at 09:06:30AM CEST, ying.xue@windriver.com wrote:
>Once we get a neighbour through looking up arp cache or creating a
>new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
>already taken. But we don't put the refcount again after it's used,
>which make the neighbour entry leaked.
>
>Signed-off-by: Ying Xue <ying.xue@windriver.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
