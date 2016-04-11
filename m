From: Pavel Emelyanov <xemul@virtuozzo.com>
Subject: Re: [PATCH net] packet: fix heap info leak in PACKET_DIAG_MCLIST
 sock_diag interface
Date: Mon, 11 Apr 2016 11:58:35 +0300
Message-ID: <570B673B.7020705@virtuozzo.com>
References: <1460285548-832-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Mathias Krause <minipli@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0107.outbound.protection.outlook.com ([157.56.112.107]:63247
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752497AbcDKJaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 05:30:30 -0400
In-Reply-To: <1460285548-832-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2016 01:52 PM, Mathias Krause wrote:
> Because we miss to wipe the remainder of i->addr[] in packet_mc_add(),
> pdiag_put_mclist() leaks uninitialized heap bytes via the
> PACKET_DIAG_MCLIST netlink attribute.
> 
> Fix this by explicitly memset(0)ing the remaining bytes in i->addr[].
> 
> Fixes: eea68e2f1a00 ("packet: Report socket mclist info via diag module")
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>
