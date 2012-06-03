From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [Announce] LARTC wiki available
Date: Sun, 3 Jun 2012 04:36:11 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1206030343400.3122@ask.diku.dk>
References: <4EFB3B2B.7060200@linuxsystems.it> <4FC8F0E4.6060102@linuxsystems.it>
 <8063b8e35d17fd072cbdc9908cf12519@njm.linuxwall.info> <4FCA2545.60702@ukfsn.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-346819181-1338690971=:3122"
Cc: Julien Vehent <julien@linuxwall.info>,
	=?iso-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>,
	lartc@vger.kernel.org, netfilter@vger.kernel.org,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>, brouer@redhat.com
To: Andy Furniss <andyqos@ukfsn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:46018 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844Ab2FCCeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2012 22:34:25 -0400
In-Reply-To: <4FCA2545.60702@ukfsn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-346819181-1338690971=:3122
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Sat, 2 Jun 2012, Andy Furniss wrote:

> Julien Vehent wrote:
>>  On 2012-06-01 12:42, Niccolò Belli wrote:
>> >  http://lartc.org is alive and kicking and there is no need for
>> >  another
>> >  wiki anymore. I'd like to thank both Bert and Carl-Daniel.
>> > 
>> >  Niccolò
>> > 
>>
>>  Very cool !
>>  I'll try to find some time and move over some of the content I have
>>  here:
>>  http://wiki.linuxwall.info/doku.php/en:ressources:dossiers:networking:traffic_control
>
> A couple of things that stand out after skimming through.
>
> DSL - Jeesper's overhead as noted in the comments is not 5 and anyway I think 
> his good work has now been superseded by stab as it allows for negative 
> overheads, which his did not.

Thanks for the credits :-)

Its been a while since I looked at that code.  I think, the 5 bytes might 
ref to the ATM header 5 + 48 = 53 bytes the ATM cell size.  But 5 is not 
used as overhead.

The linklayer ATM hack is to adjust the rtable array, that the kernel uses 
for lookups.  The problem is that the rtable array only have an 8 bytes 
"resolution" (well depend on cell_log), thus to get this aligned, I use 
the ATM payload size of 48, when populating the rtable array.  Then 
when storing the "data" I the rtable array I use *53 byte ATM cell size.

> man tc-stab has clear and good explanations and examples.

Good to see some documentation on stab, I always found it difficult to 
use.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-346819181-1338690971=:3122--
