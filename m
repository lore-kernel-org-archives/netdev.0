From: Patrick McHardy <kaber@trash.net>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Thu, 22 May 2008 17:28:58 +0200
Message-ID: <4835913A.4020909@trash.net>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net> <4835ABD2.B932.00FE.0@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrik De Bie <ulrik.debie@newtec.eu>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Kris Op de Beeck <kris.op.de.beeck@newtec.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40243 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbYEVP3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 11:29:00 -0400
In-Reply-To: <4835ABD2.B932.00FE.0@newtec.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kris Op de Beeck wrote:
> 
>>>> On 22/05/2008 at 16:57, in message <483589C0.4080006@trash.net>, Patrick
> McHardy <kaber@trash.net> wrote:
>> Please try loading ipt_LOG and executing
>>
>> "echo 255 >/proc/sys/net/netfilter/nf_conntrack_log_invalid"
>>
>> and see if something shows up in the ringbuffer.
> 
> [  917.584000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.23 DST=10.9.9.22 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=3257 DF PROTO=TCP SPT=40018 DPT=80 SEQ=1136088214 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A00025B1C0000000001030307) UID=1000
> [  918.800000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.22 DST=10.9.9.21 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=26411 DF PROTO=TCP SPT=47713 DPT=80 SEQ=1041054567 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A00025C4C0000000001030307) UID=1000
> [  921.800000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.22 DST=10.9.9.21 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=26412 DF PROTO=TCP SPT=47713 DPT=80 SEQ=1041054567 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A00025F3A0000000001030307) UID=1000
> [  924.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25744 DF PROTO=TCP SPT=52775 DPT=80 SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000261930000000001030307) UID=1000
> [  927.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25745 DF PROTO=TCP SPT=52775 DPT=80 SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000264810000000001030307) UID=1000
> 
> For those DST ip addresses I've got failures

Which kernel is this test running on? That message
is gone since 2.6.22.
