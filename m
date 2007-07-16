From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] [IrDA] Fix IrDA build failure
Date: Mon, 16 Jul 2007 15:56:26 +0400
Message-ID: <20070716115624.GA4492@2ka.mipt.ru>
References: <20070716111715.GB22757@mail.solidboot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: davem@davemloft.net, eric.y.miao@gmail.com, sam@ravnborg.org,
	netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	stable@kernel.org
To: Samuel Ortiz <samuel.ortiz@solidboot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46955 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468AbXGPL5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 07:57:07 -0400
Content-Disposition: inline
In-Reply-To: <20070716111715.GB22757@mail.solidboot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Samuel.

On Mon, Jul 16, 2007 at 02:17:15PM +0300, Samuel Ortiz (samuel.ortiz@solidboot.com) wrote:
> This is due to the irda_init fix recently added, where we call __exit
> routines from an __init one. It is a build failure that I didn't catch
> because it doesn't show up when building IrDA as a module. My apologies
> for that.

What about having all of them __devinit/__devexit?

-- 
	Evgeniy Polyakov
