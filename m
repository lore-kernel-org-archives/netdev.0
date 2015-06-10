From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Wed, 10 Jun 2015 17:13:43 -0400
Message-ID: <20150610211342.GT588@gospo.home.greyhouse.net>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, bblanco@plumgrid.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35455 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbbFJVNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 17:13:47 -0400
Received: by qgg3 with SMTP id 3so20554752qgg.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 14:13:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 01:56:02PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
> port does not support switchdec_port_attr_set op.  Don't BUG() if
> -EOPNOTSUPP is returned.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>

Looks good since -EOPNOTSUPP seems to be the safe failure case when
switchdev is enabled or not.

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
