From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 2/4] switchdev: skip over ports returning
 -EOPNOTSUPP when recursing ports
Date: Fri, 9 Oct 2015 06:27:53 +0200
Message-ID: <20151009042753.GB2161@nanopsycho.orion>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35236 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027AbbJIE16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:27:58 -0400
Received: by wicge5 with SMTP id ge5so51446658wic.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 21:27:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444357400-37078-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 09, 2015 at 04:23:18AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>This allows us to recurse over all the ports, skipping over unsupporting
>ports.  Without the change, the recursion would stop at first unsupported
>port.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
