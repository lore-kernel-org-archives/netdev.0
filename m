From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init
Date: Thu, 25 Sep 2008 11:38:12 +0200
Message-ID: <48DB5C04.9050308@redhat.com>
References: <48D25BA2.6070008@redhat.com> <Pine.LNX.4.64.0809182235550.4742@wrl-59.cs.helsinki.fi> <48D3A381.1080500@redhat.com> <Pine.LNX.4.64.0809210100020.16838@wrl-59.cs.helsinki.fi> <48D9FE65.40709@redhat.com> <20080924211021.GB9746@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56995 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669AbYIYJi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 05:38:28 -0400
In-Reply-To: <20080924211021.GB9746@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Ivan Vecera <ivecera@redhat.com> :
> [...]
>> OK :-), I hope the patch below is finally the right one.
> 
> My approval ratings won't surge today.
> 
> Is there a specific explanation for the 10 us delay ?
> 
> Realtek's 8168 / 8169 / 8101 drivers all use a (wildly copy'pasted ?)
> 10 ms delay. I would not mind a 10 ms sleep.
'pci_vpd_pci22_wait' uses 100us(10x10us delay) for reading, there is 1ms
(100x10us delay) in my patch, because 100us max. delay was too little for
Realtek. I tried the patch (with 1ms) on 8169,8168b and 8102e HW without
any problem. IMHO Realtek's 10ms delay (usually used for VPD write access)
is too much...

Ivan

