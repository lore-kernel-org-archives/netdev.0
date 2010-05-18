From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] cnic: Return SPQ credit to bnx2x after ring setup
 and shutdown.
Date: Tue, 18 May 2010 15:17:20 -0700 (PDT)
Message-ID: <20100518.151720.129750785.davem@davemloft.net>
References: <1274218373-16324-1-git-send-email-mchan@broadcom.com>
	<1274218373-16324-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755378Ab0ERWRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:17:11 -0400
In-Reply-To: <1274218373-16324-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 18 May 2010 14:32:53 -0700

> Everytime the iSCSI ring finishes setup or shutdown, we need to return
> the SPQ (slow path queue) credit to the bnx2x driver.  Without this step,
> the SPQ will eventually be full causing iSCSI to fail.  This can happen
> after 3 or 4 MTU changes for example.
> 
> Add code to wait for these slow path commands to complete in the RX ring
> and return the SPQ credit to bnx2x.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
