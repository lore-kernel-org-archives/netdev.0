From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Fri, 12 Jun 2015 13:17:34 -0400
Message-ID: <20150612171732.GD588@gospo.home.greyhouse.net>
References: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, bblanco@plumgrid.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:34751 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbFLRRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 13:17:32 -0400
Received: by yhid80 with SMTP id d80so16410106yhi.1
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 10:17:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434035941-13665-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 08:19:01AM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Fix a BUG_ON() where CONFIG_NET_SWITCHDEV is set but the driver for a
> bridged port does not support switchdev_port_attr_set op.  Don't BUG_ON()
> if -EOPNOTSUPP is returned.
> 
> Also change BUG_ON() to netdev_err since this is a normal error path and
> does not warrant the use of BUG_ON(), which is reserved for unrecoverable
> errs.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>

This is less aggressive -- good call.

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
