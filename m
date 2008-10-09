From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] sctp: Fix the SNMP number of
 SCTP_MIB_CURRESTAB
Date: Thu, 09 Oct 2008 14:32:37 -0700 (PDT)
Message-ID: <20081009.143237.155401326.davem@davemloft.net>
References: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
	<1223558975-1550-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755761AbYJIVdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:33:01 -0400
In-Reply-To: <1223558975-1550-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu,  9 Oct 2008 09:29:33 -0400

> RFC3873 defined SCTP_MIB_CURRESTAB:
>   sctpCurrEstab OBJECT-TYPE
>     SYNTAX         Gauge32
>     MAX-ACCESS     read-only
>     STATUS         current
>     DESCRIPTION
>          "The number of associations for which the current state is
>          either ESTABLISHED, SHUTDOWN-RECEIVED or SHUTDOWN-PENDING."
>     REFERENCE
>          "Section 4 in RFC2960 covers the SCTP   Association state
>          diagram."
> 
> If the T4 RTO timer expires many times(timeout), the association will enter
> CLOSED state, so we should dec the number of SCTP_MIB_CURRESTAB, not inc the
> number of SCTP_MIB_CURRESTAB.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
