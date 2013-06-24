From: Pratik Pujar <pratik.pujar@qlogic.com>
Subject: RE: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
 qlcnic_hardware_context
Date: Mon, 24 Jun 2013 18:17:04 +0000
Message-ID: <446476BDCB53C441A1847D74CB603378DA72D5@avmb3.qlogic.org>
References: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371888727-16422-6-git-send-email-jitendra.kalsaria@qlogic.com>
 <1371898428.3137.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Joe Perches <joe@perches.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.189] ([213.199.154.189]:45567 "EHLO
	db8outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752472Ab3FXSSW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 14:18:22 -0400
In-Reply-To: <1371898428.3137.5.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: Joe Perches [mailto:joe@perches.com]
>Sent: 22 June 2013 16:24
>To: Jitendra Kalsaria
>Cc: David Miller; netdev; Sony Chacko; Shahed Shaikh; Dept-NX Linux NIC
>Driver; Pratik Pujar
>Subject: Re: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
>qlcnic_hardware_context
>
>On Sat, 2013-06-22 at 04:12 -0400, Jitendra Kalsaria wrote:
>> From: Pratik Pujar <pratik.pujar@qlogic.com>
>
>This isn't really a cleanup.
>It's allowing more capabilities.

The driver was dealing with extra capabilities but separate variables were used for these. Now instead of using separate variables, clubbed in a single array. 

>
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>[]
>> @@ -449,7 +449,7 @@ struct qlcnic_hardware_context {
>>  	u16 max_pci_func;
>>
>>  	u32 capabilities;
>> -	u32 capabilities2;
>> +	u32 extra_capability[3];
>
>Also, it looks like it's used as a bitfield.
>
>I suggest instead using an array of ulongs and something like tg3's use of
>tg3_flag_set|tg3_flag_clear.
>
>

The extra_capability is read-only field. Driver does not perform any set/clear operations on this.

Thanks,
Pratik.
