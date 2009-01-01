From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.28-03117: WARNING: at net/ipv4/tcp_input.c:2504 tcp_mark_head_lost()
Date: Thu, 1 Jan 2009 21:30:00 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901012123280.4692@wrl-59.cs.helsinki.fi>
References: <20090101124114.GA4281@orion>  <Pine.LNX.4.64.0901011627020.4692@wrl-59.cs.helsinki.fi>
 <a4423d670901010650iefe98e5je2e53d9f7d74df81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-288813141-1230838200=:4692"
Cc: Netdev <netdev@vger.kernel.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39293 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586AbZAATaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2009 14:30:05 -0500
In-Reply-To: <a4423d670901010650iefe98e5je2e53d9f7d74df81@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-288813141-1230838200=:4692
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 1 Jan 2009, Alexander Beregalov wrote:

> 2009/1/1 Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>:
>> On Thu, 1 Jan 2009, Alexander Beregalov wrote:
>>
>>> WARNING: at net/ipv4/tcp_input.c:2504 tcp_mark_head_lost+0x1df/0x200()
>>
>> ...snip...
>>
>> Can you reproduce it?
>
> No, I do not know how to reproduce it.

Yeah, it's probably the same old miscount I've not yet been able to track 
down... I have some plans though by using kerneloops.org to collect the 
necessary counters & state since nobody seems to be able to hit it except 
once in a life time. Quite likely it has been there nearly forever but I 
only started tracking them around 2.6.21-25 timeframe (I don't remember 
the exact version anymore). Anyway, it's just a miscount that mostly
affects TCP packet timing so that there might be more delays and 
burstiness (during that rare event, however, the timescale is likely so
short that no human can notice).


-- 
 i.
---696208474-288813141-1230838200=:4692--
