From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 1/4] net core: Add protodown support.
Date: Wed, 8 Jul 2015 18:08:42 -0700
Message-ID: <CACcJQnRd4zg0Sr_5GuUf86C_pB9y5Qrdrv7h_o2konWOFqRa_w@mail.gmail.com>
References: <1436389465-3077-2-git-send-email-anuradhak@cumulusnetworks.com>
	<559DAD30.20806@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:34376 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbGIBIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 21:08:44 -0400
Received: by lagx9 with SMTP id x9so236316966lag.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 18:08:43 -0700 (PDT)
In-Reply-To: <559DAD30.20806@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2015 at 4:07 PM, Jonathan Toppins
<jtoppins@cumulusnetworks.com> wrote:
> On 7/8/15 5:04 PM, anuradhak@cumulusnetworks.com wrote:
>>
>> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
>> index 9cf2394..8d60fe7 100644
>> --- a/include/uapi/linux/if.h
>> +++ b/include/uapi/linux/if.h
>> @@ -156,6 +156,12 @@ enum {
>>         IF_LINK_MODE_DORMANT,   /* limit upward transition to dormant */
>>   };
>>
>> +/* proto_flags - port state information can be passed to the switch
>> driver and
>> + * used to determine the phys state of the switch port */
>> +enum {
>> +       IF_PROTOF_DOWN          = 1<<0  /* set switch port phys state down
>> */
>
>
> It might be better to use BIT(0) provided by linux/bitopts.h
>
>> +};
>> +
>
>
Ack.
