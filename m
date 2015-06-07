From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] wan: dscc4: use msecs_to_jiffies for conversions
Date: Sun, 7 Jun 2015 10:32:43 +0200
Message-ID: <20150607083243.GA30987@electric-eye.fr.zoreil.com>
References: <1433580066-1237-1-git-send-email-hofrat@osadl.org>
 <20150607.001351.1615444562432115091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hofrat@osadl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35059 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbbFGIdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 04:33:00 -0400
Content-Disposition: inline
In-Reply-To: <20150607.001351.1615444562432115091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Whoever wrote these things probably wanted whatever this amounts
> to when HZ=100, so that is the only valid transformation you can
> make to fix this up here.

It's linux kernel illiterate style from 13 years ago but I commented
dscc4_pci_reset.

wait_ack_cec and xpr_ack are dumb busy loops that break on short integer
sign change. Hackish hint.

> Otherwise you seriously risk breaking the driver.

How seriously is hard to tell. I've never tried it at really low line
rates though.

Please apply.

Thanks.

-- 
Ueimor
