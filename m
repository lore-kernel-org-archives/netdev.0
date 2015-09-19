From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 5/7] rocker: add FDB cleanup timer
Date: Sat, 19 Sep 2015 08:56:48 +0200
Message-ID: <20150919065648.GE2067@nanopsycho.orion>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34126 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbbISG4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 02:56:50 -0400
Received: by wicfx3 with SMTP id fx3so87592285wic.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 23:56:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442606151-50429-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 18, 2015 at 09:55:49PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Add a timer to each rocker switch to do FDB entry cleanup by ageing out
>expired entries.  The timer scheduling algo is copied from the bridge
>driver, for the most part, to keep the firing of the timer to a minimum.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
