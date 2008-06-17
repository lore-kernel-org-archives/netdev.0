From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] sctp: fix error path in sctp_proc_init
Date: Tue, 17 Jun 2008 16:29:59 +0400
Message-ID: <4857AE47.1030008@openvz.org>
References: <4857AE19.9050708@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60820 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955AbYFQMc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 08:32:28 -0400
In-Reply-To: <4857AE19.9050708@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> After the sctp_remaddr_proc_init failed, the proper rollback is
> not the sctp_remaddr_proc_exit, but the sctp_assocs_proc_exit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Oops, sorry - this is for net-next-2.6.
