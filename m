From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: xgene: Fix the compilation
 error "error: implicit declaration of function 'acpi_evaluate_integer'"
 for CONFIG_ACPI=n.
Date: Wed, 08 Jul 2015 14:44:57 -0700 (PDT)
Message-ID: <20150708.144457.1671326667513366241.davem@davemloft.net>
References: <1436169862-1372-1-git-send-email-stripathi@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kchudgar@apm.com, patches@apm.com, isubramanian@apm.com
To: stripathi@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbbGHVo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:44:58 -0400
In-Reply-To: <1436169862-1372-1-git-send-email-stripathi@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suman Tripathi <stripathi@apm.com>
Date: Mon,  6 Jul 2015 13:34:22 +0530

> This patch guards the acpi_evaluate_interger function as it fails
> the build for CONFIG_ACPI=n.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Suman Tripathi <stripathi@apm.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

While the net-next tree is closed, all work and bug fixes should occur against
'net' which trumps the 'net-next' tree during this time.

If you had investigated, you would have seen that this build failure had
been fixed in the 'net' tree for some time now.
