From: "Kris Op de Beeck" <kris.op.de.beeck@newtec.eu>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Thu, 22 May 2008 17:34:20 +0200
Message-ID: <4835AE9B.B932.00FE.0@newtec.eu>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net>
 <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ulrik De Bie" <ulrik.debie@newtec.eu>, <netdev@vger.kernel.org>,
	"Netfilter Development Mailinglist" <netfilter-devel@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4835913A.4020909@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



>>> On 22/05/2008 at 17:28, in message <4835913A.4020909@trash.net>, Patrick
McHardy <kaber@trash.net> wrote:
> Kris Op de Beeck wrote:
>> 
>>>>> On 22/05/2008 at 16:57, in message <483589C0.4080006@trash.net>, Patrick
>> McHardy <kaber@trash.net> wrote:
>>> Please try loading ipt_LOG and executing
>>>
>>> "echo 255 >/proc/sys/net/netfilter/nf_conntrack_log_invalid"
>>>
>>> and see if something shows up in the ringbuffer.
>> 
>> [  917.584000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.23 DST=10.9.9.22 
> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=3257 DF PROTO=TCP SPT=40018 DPT=80 
> SEQ=1136088214 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
> (020405B40402080A00025B1C0000000001030307) UID=1000
>> [  918.800000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.22 DST=10.9.9.21 
> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=26411 DF PROTO=TCP SPT=47713 DPT=80 
> SEQ=1041054567 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
> (020405B40402080A00025C4C0000000001030307) UID=1000
>> [  921.800000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.22 DST=10.9.9.21 
> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=26412 DF PROTO=TCP SPT=47713 DPT=80 
> SEQ=1041054567 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
> (020405B40402080A00025F3A0000000001030307) UID=1000
>> [  924.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 
> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25744 DF PROTO=TCP SPT=52775 DPT=80 
> SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
> (020405B40402080A000261930000000001030307) UID=1000
>> [  927.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 
> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25745 DF PROTO=TCP SPT=52775 DPT=80 
> SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
> (020405B40402080A000264810000000001030307) UID=1000
>> 
>> For those DST ip addresses I've got failures
> 
> Which kernel is this test running on? That message
> is gone since 2.6.22.

s3p@burnin:~$ uname -a
Linux burnin 2.6.22-14-generic #1 SMP Sun Oct 14 23:05:12 GMT 2007 i686 GNU/Linux

This was the config where I detected the problem. (Ubuntu 7.10)

Newtec will be present at the following exhibitions :

CommunicAsia, 17-20 June, Singapore, Booth 6B2-01

*** e-mail confidentiality footer ***
This message and any attachments thereto are confidential. They may also
be privileged or otherwise protected by work product immunity or other
legal rules. If you have received it by mistake, please let us know by
e-mail reply and delete it from your system; you may not copy this
message or disclose its contents to anyone.
E-mail transmission cannot be guaranteed to be secure or error free as
information could be intercepted, corrupted, lost, destroyed, arrive
late or incomplete, or contain viruses. The sender therefore is in no
way liable for any errors or omissions in the content of this message,
which may arise as a result of e-mail transmission. If verification is
required, please request a hard copy.

