From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] net: cadence: Add architecture dependencies
Date: Mon, 14 Apr 2014 19:14:38 +0200
Message-ID: <20140414191438.444d6ed8@endymion.delvare>
References: <20140414141151.5ee5434d@endymion.delvare>
	<534BDBC9.8000509@atmel.com>
	<20140414.125439.1807278146637759316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	grant.likely@linaro.org, robh+dt@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39083 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbaDNROm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 13:14:42 -0400
In-Reply-To: <20140414.125439.1807278146637759316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, 14 Apr 2014 12:54:39 -0400 (EDT), David Miller wrote:
> From: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date: Mon, 14 Apr 2014 14:59:53 +0200
> 
> > Well, do we really need the adding of these dependencies? I though that
> > we were moving toward the decreasing of dependency checks in Kconfig...
> 
> Yeah I really don't want to apply this, I like that this driver gets enabled
> and compile tested when I do my standard allmodconfig/allyesconfig builds.

They will still be. allmodconfig/allyesconfig enables COMPILE_TEST. Is
the world not wonderful? :)

-- 
Jean Delvare
SUSE L3 Support
