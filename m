From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT] qlcnic: avoid using reset_devices as it may
 become obsolete.
Date: Sun, 28 Nov 2010 10:48:15 -0800 (PST)
Message-ID: <20101128.104815.104066775.davem@davemloft.net>
References: <1290511521-5773-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36549
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866Ab0K1Srt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:47:49 -0500
In-Reply-To: <1290511521-5773-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue, 23 Nov 2010 03:25:21 -0800

> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> 
> In kdump environment do not depend upon reset_devices parameter
> to reset the pci function as this parameter may become obsolete.
> Instead use an adapter specific mechanism to determine if the pci
> function needs to be reset.
> 
> Per function refcount is maintained in driver, which is set in probe
> and reset in remove handler of adapter. If the probe detects the count
> as non zero then reset the function.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
