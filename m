From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 4/5] unix_diag: Report memory usage info
Date: Wed, 28 Dec 2011 22:55:59 +0400
Message-ID: <4EFB663F.6050009@parallels.com>
References: <4EFB1C0E.4060004@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38636 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754440Ab1L1S4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 13:56:08 -0500
In-Reply-To: <4EFB1C0E.4060004@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2011 05:39 PM, Pavel Emelyanov wrote:
> Symmetrical to inet sockets, but unix only have two meaningful
> values -- the wmem allocation and sndbuf.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

David, taking into account you don't apply patch #3, please, ignore this and the 5th
ones (but your feedback about whether reporting the ack backlog info in the same place
whith the meminfo is still required). I will reimplement them according to the inet
meminfo rework.

Thanks,
Pavel
