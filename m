From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Wed, 30 May 2012 07:29:20 +0200
Message-ID: <1338355760.2760.8.camel@edumazet-glaptop>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
	 <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
	 <20120517.160937.586334759945738635.davem@davemloft.net>
	 <20120517202152.GB19321@hmsreliant.think-freely.org>
	 <1337691919.3361.189.camel@edumazet-glaptop>
	 <20120529193348.GB9258@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43700 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab2E3F3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 01:29:25 -0400
Received: by weyu7 with SMTP id u7so3094755wey.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 22:29:24 -0700 (PDT)
In-Reply-To: <20120529193348.GB9258@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 15:33 -0400, Neil Horman wrote:

> Eric,
> 	Just FYI, I sent a series upstream to implement autoloading of generic
> netlink families.  Please be awarem, that I've tested these with a hacked
> version of dropwatch, and it works great, but with the normal version of
> dropwatch, the drop_monitor module still doesn't autoload.  This is due to libnl
> not explicitly requesting a family when genl_ctrl_family_resolve is called.
> Instead of trying to load the module, it dumps the existing registered families
> via a NLM_F_DUMP message.  I'm working on updating libnl to correct this
> currently and will cc you on the patch.

Excellent, thanks Neil
