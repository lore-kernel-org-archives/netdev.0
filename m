From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-26 4/5] cxgb4vf: Quiesce Virtual Interfaces on shutdown ...
Date: Mon, 14 Feb 2011 11:01:22 -0800
Message-ID: <201102141101.22326.leedom@chelsio.com>
References: <1297472423-15672-1-git-send-email-leedom@chelsio.com> <1297472423-15672-5-git-send-email-leedom@chelsio.com> <F12A7E83-6F8D-4558-A7B5-174D9509891C@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22427 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab1BNTB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 14:01:26 -0500
In-Reply-To: <F12A7E83-6F8D-4558-A7B5-174D9509891C@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
| Date: Friday, February 11, 2011 11:17 pm
| 
| 
| You could invoke pci_reset_function as an alternative, that would make sure
| FLR happens.

  I'd love to do that but pci_reset_function() ends up taking the device 
semaphore in the underlaying routine pci_dev_reset().  I used to call 
pci_reset_function() in my probe() routine till 2.6.31 where that lock as added 
... which resulted in an instant self-deadlock ...

Casey
