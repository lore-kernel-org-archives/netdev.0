From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sctp: malloc enough room for asconf-ack chunk
Date: Fri, 01 Apr 2011 21:46:10 -0700 (PDT)
Message-ID: <20110401.214610.200375443.davem@davemloft.net>
References: <4D959D2E.40605@cn.fujitsu.com>
	<4D959E1F.80504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750839Ab1DBEqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 00:46:48 -0400
In-Reply-To: <4D959E1F.80504@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 01 Apr 2011 17:42:55 +0800

> Sometime the ASCONF_ACK parameters can equal to the fourfold of
> ASCONF parameters, this only happend in some special case:
> 
>   ASCONF parameter is :
>     Unrecognized Parameter (4 bytes)
>   ASCONF_ACK parameter should be:
>     Error Cause Indication parameter (8 bytes header)
>      + Error Cause (4 bytes header)
>        + Unrecognized Parameter (4bytes)
> 
> Four 4bytes Unrecognized Parameters in ASCONF chunk will cause panic.
 ...
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
