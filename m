From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net-next 2/8] qlcnic: Secondary unicast MAC address
 support.
Date: Fri, 21 Jun 2013 17:45:53 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E33FD33@avmb2.qlogic.org>
References: <1371834609.19215.47.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:58013 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423535Ab3FURp7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 13:45:59 -0400
In-Reply-To: <1371834609.19215.47.camel@joe-AO722>
Content-Language: en-US
Content-ID: <D01D604387E60B4180AF3ADCC371D272@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/13 10:10 AM, "Joe Perches" <joe@perches.com> wrote:

>On Fri, 2013-06-21 at 12:30 -0400, Jitendra Kalsaria wrote:
>> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>> 
>> Add support for configuring secondary unicast address which
>> will use existing HW filters to store all the unicast MAC
>> addresses and prevent device going into promiscuous mode.
>
>[]
>
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>[]
>> @@ -421,6 +421,7 @@ struct qlcnic_hardware_context {
>> +	u8 max_uc_count;
>
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
>>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
>[]
>> +#define QLC_83XX_MAX_UC_COUNT			4096
>
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
>>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
>[]
>> +#define QLCNIC_MAX_UC_COUNT		512
>
>These #defines don't seem right.
>There's no way to fit these values in a u8.

Thanks for pointing it, I will fix it and resubmit these series again.
