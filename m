From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 20:57:08 -0500
Message-ID: <48A390F4.5080101@opengridcomputing.com>
References: <adatzdoiklo.fsf@cisco.com>	<20080813.161237.10205799.davem@davemloft.net>	<48A389DB.9050002@opengridcomputing.com> <20080813.183755.72334968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, rick.jones2@hp.com, jgarzik@pobox.com,
	swise@opengridcomputing.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080813.183755.72334968.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tom Tucker <tom@opengridcomputing.com>
> Date: Wed, 13 Aug 2008 20:26:51 -0500
>
>   
>> Can you explain how this "information" somehow doesn't qualify as 
>> "state". Doesn't the next expected sequence number at the very least 
>> need to be updated? una? etc...?
>>
>> Could you also include the "non-state-full" information necessary to do 
>> iSCSI header digest validation, data placement, and marker removal? 
>>     
>
> It's stateless because the full packet traverses the real networking
> stack and thus can be treated like any other packet.
>
> The data placement is a side effect that the networking stack can
> completely ignore if it chooses to.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
Ok. Maybe we're getting somewhere here ... or at least I am :-)

I'm not trying to be pedantic here but let me try and restate what I 
think you said above:

- The "header" traverses the real networking stack
- The "payload" is placed either by by the hardware if possible or by 
the native stack if on the exception path
- The "header" may aggregate multiple  PDU (RSO)
- Data ready indications are controlled entirely by the software/real 
networking stack

Thanks,
Tom

