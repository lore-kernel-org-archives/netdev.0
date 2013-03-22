From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: increase inner ip id during
 encapsulated tso
Date: Fri, 22 Mar 2013 10:23:57 -0400 (EDT)
Message-ID: <20130322.102357.1296142409121292885.davem@davemloft.net>
References: <1363916305-15690-1-git-send-email-dmitry@broadcom.com>
	<1363926874.4431.57.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com, maze@google.com, jesse@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933303Ab3CVOX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:23:59 -0400
In-Reply-To: <1363926874.4431.57.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Mar 2013 21:34:34 -0700

> On Fri, 2013-03-22 at 03:38 +0200, Dmitry Kravkov wrote:
>> 57712/578xx devices during handling of encapsulated TSO can
>> properly increase ip id for only one ip header.
>> The patch selects inner header to be increased.
>> 
>> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>> CC: Eilon Greenstein <eilong@broadcom.com>
>> CC: Ariel Elior <ariele@broadcom.com>
>> CC: Maciej Zenczykowski <maze@google.com>
>> CC: Jesse Gross <jesse@nicira.com>
>> ---
>> tested over 1bc277f79
>> ---
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   22 ++++++++++------------
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   |    2 ++
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h   |    3 ++-
>>  4 files changed, 15 insertions(+), 13 deletions(-)
> 
> Fine, GRO is back 
> 
> Reported-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied.
