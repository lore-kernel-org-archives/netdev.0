From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lro: IP fragment checking
Date: Mon, 01 Dec 2008 01:41:01 -0800 (PST)
Message-ID: <20081201.014101.33453764.davem@davemloft.net>
References: <4933A74F.3050809@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tklein@de.ibm.com, raisch@de.ibm.com, jb.billaud@gmail.com,
	hering2@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46912
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750961AbYLAJlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 04:41:01 -0500
In-Reply-To: <4933A74F.3050809@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Mon, 01 Dec 2008 09:58:55 +0100

> This patch prevents that ip fragmented TCP packets are considered vaild
> for aggregation

We discussed this last week.

The things feeding packets into the LRO machinery should make this
check, and that could be a hardware LRO assist.
