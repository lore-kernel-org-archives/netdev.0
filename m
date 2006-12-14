From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25 2/7] Fix unchecked ax25_protocol_register uses.
Date: Thu, 14 Dec 2006 15:52:44 -0800 (PST)
Message-ID: <20061214.155244.131915970.davem@davemloft.net>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
	<11661361342093-git-send-email-ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752006AbWLNXwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:52:44 -0500
To: ralf@linux-mips.org
In-Reply-To: <11661361342093-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 14 Dec 2006 23:42:08 +0100

> Replace ax25_protocol_register by ax25_register_pid which assumes the
> caller has done the memory allocation.  This allows replacing the
> kmalloc allocations entirely by static allocations.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
