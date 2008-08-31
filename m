From: Daniele Lacamera <root@danielinux.net>
Subject: Re: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Sun, 31 Aug 2008 21:19:38 +0200
Message-ID: <48BAEECA.80906@danielinux.net>
References: <48BAE26A.4060002@danielinux.net> <20080831190916.GA15931@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, angelo.tornese@gmail.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:2567 "EHLO
	mail.danielinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753AbYHaTTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 15:19:32 -0400
In-Reply-To: <20080831190916.GA15931@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi.
>
> On Sun, Aug 31, 2008 at 08:26:50PM +0200, Daniele Lacamera (root@danielinux.net) wrote:
> This will also increase number of allocations in the fast path, isn't
> it? This overhead is not acceptible.
>   
Hi Evgeniy,

fast path? I don't think so... the modules allocate the ca_priv once per 
connection, at the beginning of the connection and only if that specific 
module needs that.
Am I missing something?

-- 
Daniele
