From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v3] candev: allow SJW user setting for
 bittiming calculation
Date: Wed, 28 Sep 2011 13:43:10 -0400 (EDT)
Message-ID: <20110928.134310.850080171959236853.davem@redhat.com>
References: <4E831803.7020409@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	socketcan-core@lists.berlios.de
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643Ab1I1RnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 13:43:16 -0400
In-Reply-To: <4E831803.7020409@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 28 Sep 2011 14:50:11 +0200

> This patch adds support for SJW user settings to not set the synchronization
> jump width (SJW) to 1 in any case when using the in-kernel bittiming
> calculation.
> 
> The ip-tool from iproute2 already supports to pass the user defined SJW
> value. The given SJW value is sanitized with the controller specific sjw_max
> and the calculated tseg2 value. As the SJW can have values up to 4 providing
> this value will lead to the maximum possible SJW automatically. A higher SJW
> allows higher controller oscillator tolerances.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.
