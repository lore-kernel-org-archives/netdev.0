From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Fri, 12 Jun 2015 07:54:48 +0200
Message-ID: <20150612055448.GA2042@nanopsycho.orion>
References: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34050 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbbFLFyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 01:54:51 -0400
Received: by wgv5 with SMTP id 5so16858086wgv.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 22:54:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 11, 2015 at 05:19:01PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Fix a BUG_ON() where CONFIG_NET_SWITCHDEV is set but the driver for a
>bridged port does not support switchdev_port_attr_set op.  Don't BUG_ON()
>if -EOPNOTSUPP is returned.
>
>Also change BUG_ON() to netdev_err since this is a normal error path and
>does not warrant the use of BUG_ON(), which is reserved for unrecoverable
>errs.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>Reported-by: Brenden Blanco <bblanco@plumgrid.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
