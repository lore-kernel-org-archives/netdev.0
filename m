From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by
 pci_match_id()
Date: Mon, 31 Mar 2014 15:01:01 +0800
Message-ID: <20140331070101.GA12529@richard>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
 <CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>
 <20140331035439.GA11288@richard>
 <CAJZOPZKOPHDoBDSd7=ytbC8MfPPD_ZKBh6qrc0iA+mRF+FD6DQ@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:56396 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbaCaHBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 03:01:14 -0400
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 31 Mar 2014 12:31:12 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 503853940048
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 12:31:08 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2V713Ng9306398
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 12:31:03 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2V713DF025555
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 12:31:05 +0530
Content-Disposition: inline
In-Reply-To: <CAJZOPZKOPHDoBDSd7=ytbC8MfPPD_ZKBh6qrc0iA+mRF+FD6DQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 07:52:20AM +0300, Or Gerlitz wrote:
>On Mon, Mar 31, 2014 at 6:54 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>
>> On Sun, Mar 30, 2014 at 09:08:06PM +0300, Or Gerlitz wrote:
>> >On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
>> >> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>> >> pci_device_id.driver_data to __mlx4_init_one during reset".
>> >>
>> >> pci_match_id() might return NULL if someone binds the driver to a device
>> >> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
>> >> before using it.
>> >>
>> >> Thanks to Bjorn who raised the problem.
>> >
>> >Well, that commit was applied to net and is now present in Linus
>> >tree... so assuming it's too late for 3.14, need to queue this for
>> >-stable
>> >
>> >Or.
>>
>> Sorry for this bothering, hope this will not block someone.
>>
>> Here is my suggestion for fixing this, not sure this is a good way to export
>> pci_match_device() to modules. This is my current solution to this problem. If
>> you have any comments, please let me know.
>>
>> ------------------------------------------------------------------------------
>> From 9361e1edd6776202c6e11dd44d3d4d72c990b111 Mon Sep 17 00:00:00 2001
>> From: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Date: Mon, 31 Mar 2014 11:34:57 +0800
>> Subject: [PATCH net-next] net/mlx4_core: match pci_device_id including dynids
>
>
>
>Your original commit went to net and same needs to be done for the fix
>

Thanks, seems I still misunderstand this rule.
I thought Amir is correct, so copyed his.

Will pay attention next time.

-- 
Richard Yang
Help you, Help me
