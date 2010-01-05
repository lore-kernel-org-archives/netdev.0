From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH NEXT 2/2] qlcnic: Qlogic ethernet driver for CNA devices
Date: Tue, 5 Jan 2010 09:08:23 -0800
Message-ID: <20100105090823.4774cf62@nehalam>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<1262697876-26206-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39884 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754247Ab0AERIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 12:08:45 -0500
In-Reply-To: <1262697876-26206-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Jan 2010 05:24:36 -0800
Amit Kumar Salecha <amit.salecha@qlogic.com> wrote:

> +
> +obj-$(CONFIG_NETXEN_NIC) := qlcnic.o

Don't you mean:
obj-$(CONFIG_QLCNIC) := qlcnic.o
