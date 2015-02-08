From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] [3.20] 2nd NFC update
Date: Sat, 07 Feb 2015 22:22:47 -0800 (PST)
Message-ID: <20150207.222247.2156834718202189785.davem@davemloft.net>
References: <20150205174757.GA24523@ribalta.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbBHGWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:22:48 -0500
In-Reply-To: <20150205174757.GA24523@ribalta.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <sameo@linux.intel.com>
Date: Thu, 5 Feb 2015 18:47:57 +0100

> Here goes one last NFC pull request for 3.20.
> 
> It brings:
> 
> - NCI NFCEE (NFC Execution Environment, typically an embedded or
>   external secure element) discovery and enabling/disabling support.
>   In order to communicate with an NFCEE, we also added NCI's logical
>   connections support to the NCI stack.
> 
> - HCI over NCI protocol support. Some secure elements only understand
>   HCI and thus we need to send them HCI frames when they're part of
>   an NCI chipset.
> 
> - NFC_EVT_TRANSACTION userspace API addition. Whenever an application
>   running on a secure element needs to notify its host counterpart,
>   we send an NFC_EVENT_SE_TRANSACTION event to userspace through the
>   NFC netlink socket.
> 
> - Secure element and HCI transaction event support for the st21nfcb
>   chipset.
> 
> Thanks in advance for pulling them in.

Pulled, thanks Sam.
