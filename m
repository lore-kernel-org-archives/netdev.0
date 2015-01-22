From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 0/9] mlx4: Fix and enhance the device reset flow
Date: Thu, 22 Jan 2015 16:05:38 +0200
Message-ID: <54C103B2.2090406@mellanox.com>
References: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0062.outbound.protection.outlook.com ([157.56.112.62]:32368
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751236AbbAVOGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 09:06:20 -0500
In-Reply-To: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/21/2015 4:45 PM, Or Gerlitz wrote:
> This series from Yishai Hadas fixes the device reset flow and adds SRIOV support.
>
> Reset flows are required whenever a device experiences errors, is unresponsive,
> or is not in a deterministic state. In such cases, the driver is expected to
> reset the HW and continue operation. When SRIOV is enabled, these requirements
> apply both to PF and VF devices.

So we spotted some problem in the SRIOV flow and prefer to fix it in a 
V1, which will be sent next week, please don't take this one.

Or.
