From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: Re: [PATCH] X25: Add ITU-T facilites
Date: Tue, 18 Oct 2005 11:48:30 -0400
Message-ID: <Pine.LNX.4.61.0510181144320.28065@chaos.analogic.com>
References: <1129513666.3747.50.camel@localhost.localdomain> <20051017022826.GA23167@mandriva.com> <1129615767.3695.15.camel@localhost.localdomain> <20051018.152318.68554424.yoshfuji@linux-ipv6.org> <20051018153702.GC23167@mandriva.com>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	<ahendry@tusc.com.au>, <eis@baty.hanse.de>,
	<linux-x25@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750834AbVJRPse@vger.kernel.org>
In-Reply-To: <20051018153702.GC23167@mandriva.com>
Content-class: urn:content-classes:message
To: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 18 Oct 2005, Arnaldo Carvalho de Melo wrote:

> Em Tue, Oct 18, 2005 at 03:23:18PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
>> In article <1129615767.3695.15.camel@localhost.localdomain> (at Tue, 18 Oct 2005 16:09:27 +1000), Andrew Hendry <ahendry@tusc.com.au> says:
>>
>>> +/*
>>> +*     ITU DTE facilities
>>> +*     Only the called and calling address
>>> +*     extension are currently implemented.
>>> +*     The rest are in place to avoid the struct
>>> +*     changing size if someone needs them later
>>> ++ */
>>> +struct x25_dte_facilities {
>>> +	unsigned int    calling_len, called_len;
>>> +	char            calling_ae[20];
>>> +	char            called_ae[20];
>>> +	unsigned char   min_throughput;
>>> +	unsigned short  delay_cumul;
>>> +	unsigned short  delay_target;
>>> +	unsigned short  delay_max;
>>> +	unsigned char   expedited;
>>> +};
>>
>> Why don't you use fixed size members?
>> And we can eliminate 8bit hole.
>>
>> struct x25_dte_facilities {
>>      u32             calling_len
>>      u32             called_len;
>
> I guess the two above can be 'u8' as they refer to calling_ae and called_ae
> that at most will be '20'?
>
>>      u8              calling_ae[20];
>>      u8              called_ae[20];
>
> - Arnaldo

At the very least put the 32-bit in the beginning and 8-bit stuff at
the end so natural alignment occurs where possible.

Cheers,
Dick Johnson
Penguin : Linux version 2.6.13.4 on an i686 machine (5589.46 BogoMips).
Warning : 98.36% of all statistics are fiction.
.

****************************************************************
The information transmitted in this message is confidential and may be privileged.  Any review, retransmission, dissemination, or other use of this information by persons or entities other than the intended recipient is prohibited.  If you are not the intended recipient, please notify Analogic Corporation immediately - by replying to this message or by sending an email to DeliveryErrors@analogic.com - and destroy all copies of this information, including any attachments, without reading or disclosing them.

Thank you.
