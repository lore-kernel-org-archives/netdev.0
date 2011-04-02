From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: fix auth_hmacs field's length of struct
 sctp_cookie
Date: Fri, 01 Apr 2011 21:46:00 -0700 (PDT)
Message-ID: <20110401.214600.116373329.davem@davemloft.net>
References: <4D959D2E.40605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865Ab1DBEqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 00:46:37 -0400
In-Reply-To: <4D959D2E.40605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 01 Apr 2011 17:38:54 +0800

> auth_hmacs field of struct sctp_cookie is used for store
> Requested HMAC Algorithm Parameter, and each HMAC Identifier
> is 2 bytes, so the length should be:
>   SCTP_AUTH_NUM_HMACS * sizeof(__u16) + 2
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
