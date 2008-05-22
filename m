From: Patrick McHardy <kaber@trash.net>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Thu, 22 May 2008 17:36:27 +0200
Message-ID: <483592FB.7070900@trash.net>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net> <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net> <4835AE9B.B932.00FE.0@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrik De Bie <ulrik.debie@newtec.eu>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Kris Op de Beeck <kris.op.de.beeck@newtec.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40369 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbYEVPg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 11:36:29 -0400
In-Reply-To: <4835AE9B.B932.00FE.0@newtec.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kris Op de Beeck wrote:
>>> [  927.204000] nf_ct_tcp: invalid SYNIN= OUT= SRC=192.168.1.30 DST=10.9.9.29 
>> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=25745 DF PROTO=TCP SPT=52775 DPT=80 
>> SEQ=2154890499 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT 
>> (020405B40402080A000264810000000001030307) UID=1000
>>> For those DST ip addresses I've got failures
>> Which kernel is this test running on? That message
>> is gone since 2.6.22.
> 
> s3p@burnin:~$ uname -a
> Linux burnin 2.6.22-14-generic #1 SMP Sun Oct 14 23:05:12 GMT 2007 i686 GNU/Linux
> 
> This was the config where I detected the problem. (Ubuntu 7.10)

Odd. I'll have a look at the ubuntu kernel.
