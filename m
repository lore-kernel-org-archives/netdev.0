From: Pratik Pujar <pratik.pujar@qlogic.com>
Subject: RE: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
 qlcnic_hardware_context
Date: Tue, 25 Jun 2013 05:04:02 +0000
Message-ID: <446476BDCB53C441A1847D74CB603378DA7A8F@avmb3.qlogic.org>
References: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371888727-16422-6-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371898428.3137.5.camel@joe-AO722>
	 <446476BDCB53C441A1847D74CB603378DA72D5@avmb3.qlogic.org>
 <1372097962.1245.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:48858
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750890Ab3FYFP3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 01:15:29 -0400
In-Reply-To: <1372097962.1245.14.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: Joe Perches [mailto:joe@perches.com]
>Sent: 24 June 2013 23:49
>To: Pratik Pujar
>Cc: Jitendra Kalsaria; David Miller; netdev; Sony Chacko; Shahed Shaikh; Dept-
>NX Linux NIC Driver
>Subject: Re: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
>qlcnic_hardware_context
>
>On Mon, 2013-06-24 at 18:17 +0000, Pratik Pujar wrote:
>> >-----Original Message-----
>> >From: Joe Perches [mailto:joe@perches.com]
>> >Sent: 22 June 2013 16:24
>> >To: Jitendra Kalsaria
>> >Cc: David Miller; netdev; Sony Chacko; Shahed Shaikh; Dept-NX Linux
>> >NIC Driver; Pratik Pujar
>> >Subject: Re: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
>> >qlcnic_hardware_context
>> >
>> >On Sat, 2013-06-22 at 04:12 -0400, Jitendra Kalsaria wrote:
>> >> From: Pratik Pujar <pratik.pujar@qlogic.com>
>> >
>> >This isn't really a cleanup.
>> >It's allowing more capabilities.
>>
>> The driver was dealing with extra capabilities but separate variables
>> were used for these. Now instead of using separate variables, clubbed
>> in a single array.
>
>What was 2 is now 3 no?
>

Yes, adapter chip exposes extra capabilities through 3 words. Driver uses only 1, as others are reserved as of now. So array extra_capability[3] is a provision for future use of these extra capabilities. 
I will change the description to structure cleanup + provision for future use of extra capabilities. 

>> >> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>> >> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
>> >[]
>> >> @@ -449,7 +449,7 @@ struct qlcnic_hardware_context {
>> >>  	u16 max_pci_func;
>> >>
>> >>  	u32 capabilities;
>> >> -	u32 capabilities2;
>> >> +	u32 extra_capability[3];
>
>

Thanks,
Pratik.
