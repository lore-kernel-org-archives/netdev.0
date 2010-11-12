From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ucc_geth: Do not bring the whole IF down when TX
 failure.
Date: Fri, 12 Nov 2010 12:24:54 -0800 (PST)
Message-ID: <20101112.122454.48521600.davem@davemloft.net>
References: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<20101112140515.GA28223@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: cbouatmailru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932661Ab0KLUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:24:30 -0500
In-Reply-To: <20101112140515.GA28223@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <cbouatmailru@gmail.com>
Date: Fri, 12 Nov 2010 17:05:15 +0300

> On Fri, Nov 12, 2010 at 02:55:08PM +0100, Joakim Tjernlund wrote:
>> ucc_geth_close lacks a cancel_work_sync(&ugeth->timeout_work)
>> to stop any outstanding processing of TX fail. However, one
>> can not call cancel_work_sync without fixing the timeout function
>> otherwise it will deadlock. This patch brings ucc_geth in line with
>> gianfar:
>> 
>> Don't bring the interface down and up, just reinit controller HW
>> and PHY.
>> 
>> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> Looks sane, thanks!
> 
> Reviewed-by: Anton Vorontsov <cbouatmailru@gmail.com>

Applied.
