From: David Hill <hilld@binarystorm.net>
Subject: Re: Fw: [Bug 39132] Starting with 3.0.0-rc6,
 masquerading seems to be broken.
Date: Fri, 05 Aug 2011 00:09:08 -0400
Message-ID: <8A188C9C23A54337A5A276BAE29DC6E0@delorimier>
References: <20110804193107.68d93727@schatten.dmk.lab>
 <alpine.LFD.2.00.1108042131040.1495@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>, Florian Mickler <florian@mickler.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:20336 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab1HEEJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 00:09:30 -0400
Received: from wolfe ([173.177.17.75]) by vl-mr-mrz22.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-8.01 (built Dec 16 2008; 32bit))
 with ESMTP id <0LPF00N6LSVT3FG0@vl-mr-mrz22.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 05 Aug 2011 00:09:29 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

    I'm not using TPROXY and I've used a blank firewall with only 
masquerading and reproduced the issue.
Nothing is in NAT/mangle nor OUTPUT  but the rules mentionned in the 
attached files to this bug.

 Francis Whittle  (Comment #18) has the same issue.

Thank you ,

Dave


----- Original Message ----- 
From: "Julian Anastasov" <ja@ssi.bg>
To: "Florian Mickler" <florian@mickler.org>
Cc: <hilld@binarystorm.net>; <netdev@vger.kernel.org>; "David Miller" 
<davem@davemloft.net>
Sent: Thursday, August 04, 2011 2:38 PM
Subject: Re: Fw: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to 
be broken.


>
> Hello,
>
> On Thu, 4 Aug 2011, Florian Mickler wrote:
>
>> Can someone take a look at this regression?
>>
>> Begin forwarded message:
>>
>> Date: Thu, 28 Jul 2011 04:51:12 GMT
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: florian@mickler.org
>> Subject: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to be
>> broken.
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=39132
>
> So, problem points again to
> "Fix ip_route_me_harder triggering ip_rt_bug" ? May be
> David C. Hill or Florian can provide some information, eg. is
> tproxy used, what NAT rules are used, any rules in OUTPUT
> hooks (NAT/mangle) and which packets are dropped.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
> -- 
> This message has been scanned for viruses and
> dangerous content by MailScanner, and is
> believed to be clean.
>
>
>
>
> -----
> No virus found in this message.
> Checked by AVG - www.avg.com
> Version: 10.0.1390 / Virus Database: 1518/3810 - Release Date: 08/04/11
> 


-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.

