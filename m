From: Patrick McHardy <kaber@trash.net>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Mon, 26 May 2008 16:21:59 +0200
Message-ID: <483AC787.6030902@trash.net>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net> <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net> <4835AE9B.B932.00FE.0@newtec.eu> <48359F66.50503@trash.net> <4836EDCE.B932.00FE.0@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrik De Bie <ulrik.debie@newtec.eu>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Kris Op de Beeck <kris.op.de.beeck@newtec.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4836EDCE.B932.00FE.0@newtec.eu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kris Op de Beeck wrote:
>>>> On 22/05/2008 at 18:29, in message <48359F66.50503@trash.net>, Patrick McHardy
> <kaber@trash.net> wrote:
 >>
>> I didn't find the reason why your kernel even has that message
>> (didn't try to hard though). Could you rerun the test with a
>> more current kernel, like 2.6.24 or 2.6.25 please?
> 
> Upgraded from Ubuntu 7.10 to 8.04
> 
> s3p@burnin:~$ uname -a
> Linux burnin 2.6.24-16-generic #1 SMP Thu Apr 10 13:23:42 UTC 2008 i686 GNU/Linux
> 
> [ 7651.979390] printk: 8 messages suppressed.
> [ 7651.979395] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=192.168.1.24 DST=10.9.9.23 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=47660 DF PROTO=TCP SPT=42451 DPT=80 SEQ=3352606539 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A001C104E0000000001030307) UID=1000
> [ 7656.667006] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=192.168.1.15 DST=10.9.9.14 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=59137 DF PROTO=TCP SPT=49734 DPT=80 SEQ=3327322852 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A001C14E50000000001030307) UID=1000

What does "grep <srcport from above> /proc/net/nf_conntrack" show
when the problem occurs?

> Nothing works now.  Can't even ping the modems...

I can't say anything about this without further information.
