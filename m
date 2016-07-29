From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 2/4] drivers: net: cpsw: fix wrong regs access in
 cpsw_remove
Date: Fri, 29 Jul 2016 14:01:59 +0530
Message-ID: <d01a86a6-4f0b-7ea7-a69d-9fcc5b2967e3@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
 <20160728175037.22053-3-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:39996 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbcG2IcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 04:32:05 -0400
In-Reply-To: <20160728175037.22053-3-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 July 2016 11:20 PM, Grygorii Strashko wrote:
> The L3 error will be generated and system will crash during unloading
> of CPSW driver if CPSW is used as module and ethX devices are down.
> This happens because CPSW can be power off by PM runtime now when ethX
> devices are down.
> 
> Hence, ensure that CPSW powered up by PM runtime before performing any
> deinitialization actions which require CPSW registers access. In case
> of PM runtime error just leave cpsw_remove() as we can't do anything
> anymore.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
