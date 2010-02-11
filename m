From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] sky2: resume clocks
Date: Wed, 10 Feb 2010 17:57:40 -0800 (PST)
Message-ID: <20100210.175740.197360090.davem@davemloft.net>
References: <20100207082353.2d0c6a93@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755547Ab0BKB50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 20:57:26 -0500
In-Reply-To: <20100207082353.2d0c6a93@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 7 Feb 2010 08:23:53 -0800

> Change the resume path to use pci write config for a couple of reasons:
> 1. pci_write_config_dword() allows for more error
>    checking of PCI health after resume.
> 
> 2. better to toggle this register on all chip types, since that
>    is what vendor driver does.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
