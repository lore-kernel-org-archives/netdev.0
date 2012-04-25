From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH BUG-FIX] udp_diag: implement idiag_get_info for udp/udplite
 to get queue information
Date: Wed, 25 Apr 2012 16:28:31 +0400
Message-ID: <4F97EDEF.60202@parallels.com>
References: <4F977A6D.1050508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	NetDev <netdev@vger.kernel.org>,
	davidshan <davidshan@tencent.com>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12577 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab2DYM3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 08:29:33 -0400
In-Reply-To: <4F977A6D.1050508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2012 08:15 AM, Shan Wei wrote:
> From: Shan Wei <davidshan@tencent.com>
> 
> When we use netlink to monitor queue information for udp socket,
> idiag_rqueue and idiag_wqueue of inet_diag_msg are returned with 0.
> 
> Keep consistent with netstat, just return back allocated rmem/wmem size.
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
