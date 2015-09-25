From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 00/10] switchdev: transaction item queue and cleanup
Date: Thu, 24 Sep 2015 20:05:39 -0700
Message-ID: <CAE4R7bDJQ6qpSZoR5iDMdOHrDsHJB4+0oRHwLEpqg4Jc3x1Gcw@mail.gmail.com>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33694 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbbIYDGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 23:06:09 -0400
Received: by obbbh8 with SMTP id bh8so73211919obb.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 20:05:58 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 1:02 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Jiri Pirko (10):
>   switchdev: rename "trans" to "trans_ph".
>   switchdev: introduce transaction item queue for attr_set and obj_add
>   switchdev: move transaction phase enum under transaction structure
>   switchdev: add switchdev_trans_ph_prepare/commit helpers
>   rocker: push struct switchdev_trans down through rocker code
>   rocker: use switchdev transaction queue for allocated memory
>   switchdev: remove "NONE" transaction phase
>   switchdev: remove "ABORT" transaction phase
>   dsa: use prepare/commit switchdev transaction helpers
>   switchdev: reduce transaction phase enum down to a boolean
>
>  Documentation/networking/switchdev.txt |  19 ++
>  drivers/net/ethernet/rocker/rocker.c   | 308 ++++++++++++++-------------------
>  include/net/switchdev.h                |  40 +++--
>  net/dsa/slave.c                        |  31 ++--
>  net/switchdev/switchdev.c              | 125 ++++++++++---
>  5 files changed, 296 insertions(+), 227 deletions(-)

Tests pass.  ACK on all.

Acked-by: Scott Feldman <sfeldma@gmail.com>
