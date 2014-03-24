From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: pass pci_dev_data to __mlx4_init_one
Date: Mon, 24 Mar 2014 17:41:22 +0800
Message-ID: <20140324094122.GA19065@richard>
References: <1395636171-17347-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAJZOPZLM+fRBqA_rkgiUO5FCd1YtzsCKN3=denHW6Tx7OHN6RQ@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:37546 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaCXJln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 05:41:43 -0400
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 24 Mar 2014 15:11:40 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 9B42E394005A
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:11:36 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2O9fTDg51249302
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:11:30 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2O9fNZ6005259
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:11:24 +0530
Content-Disposition: inline
In-Reply-To: <CAJZOPZLM+fRBqA_rkgiUO5FCd1YtzsCKN3=denHW6Tx7OHN6RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 08:40:42AM +0200, Or Gerlitz wrote:
>On Mon, Mar 24, 2014 at 6:42 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>
>> The second parameter of __mlx4_init_one() is used to identify whether the
>> pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
>> this information is missed.
>
>
>This patch isn't fixing something in 3.14, right? if this is the case
>I assume it's for net-next, please put a "net" or "net-next"
>indication (next-time)
>
>Or.
>

Or,

Thanks for your suggestion. I will pay attention next time. :-)

BTW, do you like the fix?


-- 
Richard Yang
Help you, Help me
