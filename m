From: "Kris Op de Beeck" <kris.op.de.beeck@newtec.eu>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Fri, 23 May 2008 16:16:18 +0200
Message-ID: <4836EDCE.B932.00FE.0@newtec.eu>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net>
 <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net>
 <4835AE9B.B932.00FE.0@newtec.eu> <48359F66.50503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ulrik De Bie" <ulrik.debie@newtec.eu>, <netdev@vger.kernel.org>,
	"Netfilter Development Mailinglist" <netfilter-devel@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.newtec.eu ([62.58.98.194]:1809 "EHLO mail.newtec.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524AbYEWOQ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 10:16:59 -0400
In-Reply-To: <48359F66.50503@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 22/05/2008 at 18:29, in message <48359F66.50503@trash.net>, Patrick McHardy
<kaber@trash.net> wrote:
> Kris Op de Beeck wrote:
>> 
>>>>> On 22/05/2008 at 17:28, in message <4835913A.4020909@trash.net>, Patrick
>> McHardy <kaber@trash.net> wrote:
>>>> [  927.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 
> 
>>> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25745 DF PROTO=TCP SPT=52775 DPT=80 
>>> SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
>>> (020405B40402080A000264810000000001030307) UID=1000
>>>> For those DST ip addresses I've got failures
>>> Which kernel is this test running on? That message
>>> is gone since 2.6.22.
>> 
>> s3p@burnin:~$ uname -a
>> Linux burnin 2.6.22-14-generic #1 SMP Sun Oct 14 23:05:12 GMT 2007 i686 
> GNU/Linux
>> 
>> This was the config where I detected the problem. (Ubuntu 7.10)
> 
> 
> I didn't find the reason why your kernel even has that message
> (didn't try to hard though). Could you rerun the test with a
> more current kernel, like 2.6.24 or 2.6.25 please?

Upgraded from Ubuntu 7.10 to 8.04

s3p@burnin:~$ uname -a
Linux burnin 2.6.24-16-generic #1 SMP Thu Apr 10 13:23:42 UTC 2008 i686 GNU/Linux

[ 7651.979390] printk: 8 messages suppressed.
[ 7651.979395] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=192.168.1.24 DST=10.9.9.23 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=47660 DF PROTO=TCP SPT=42451 DPT=80 SEQ=3352606539 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A001C104E0000000001030307) UID=1000
[ 7656.667006] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=192.168.1.15 DST=10.9.9.14 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=59137 DF PROTO=TCP SPT=49734 DPT=80 SEQ=3327322852 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A001C14E50000000001030307) UID=1000

Nothing works now.  Can't even ping the modems...




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

