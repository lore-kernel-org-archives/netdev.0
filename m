From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [LARTC] ESFQ: request for user input
Date: Sun, 24 Jun 2007 16:45:28 -0700
Message-ID: <467F0218.6010400@fatooh.org>
References: <467ECB0C.6020105@fatooh.org> <467EDE48.307@trash.net> <467EF9B6.3040801@fatooh.org> <467F0106.1070103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lartc <lartc@mailman.ds9a.nl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:51067 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbXFXXp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 19:45:27 -0400
In-Reply-To: <467F0106.1070103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Patrick McHardy wrote:
>>>> Should ESFQ be merged into SFQ or remain as a separate qdisc?
>>>>       
>>> I've CCed netdev. I think merging parts of ESFQ (dynamic depth and
>>> flow number) would make a lot of sense, but I'm intending to submit
>>> an alternative to the ESFQ hashing scheme for 2.6.23:
>>>
>>> http://www.mail-archive.com/netdev@vger.kernel.org/msg39156.html
>>>     
>> Nice. I wasn't aware of that. Your patch looks like it supersedes ESFQ's
>> hashing, so, if it gets applied, that already removes a large chunk of
>> the differences between SFQ and ESFQ.
>>
>> If I don't hear any opposition, then I'll keep an eye out for when your
>> patch gets accepted (assuming it does) and then submit patch(es) porting
>> the rest of ESFQ's features to SFQ.
>>   
> 
> I think it would be best if you would start posting patches
> to add the missing features (without the hash changes) to SFQ,
> if you're quick this may already go in during the 2.6.23 merge
> window. My changes are mostly independant of yours, if there
> are any clashes the one who goes last will just have to rediff
> their patches :)
> 
> Since you need to pass additional parameters to SFQ for your
> changes, have a look at my rtnetlink compat attribute patch:
> 
> http://article.gmane.org/gmane.linux.network/64851

Ok, I'll work on it later. Thanks.

-Corey

