From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Wed, 21 Oct 2009 10:40:00 +0200
Message-ID: <4ADEC8E0.5020709@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com> <4ADDE4C4.5080501@hp.com> <4ADEC076.2030105@codefidence.com> <20091021082109.GE8704@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	ori@comsleep.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:45717 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbZJUIkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:40:02 -0400
In-Reply-To: <20091021082109.GE8704@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,


Florian Westphal wrote:

> Gilad Ben-Yossef <gilad@codefidence.com> wrote:
>   
>> The point is that even then you are more then likely to wish to turn
>> off these options to specific destination and routes (that go over
>> said exotic link) and keep using them over others - e.g. timestamp
>> OK for local LAN, but for default route that goes over exotic TCP/IP
>> over carrier penguins turn it off.
>>     
>
> If you need a bandaid solution, its is possible to replace tcp
> options with NOOPs using netfilters TCPOPTSTRIP target.
>
> There is also an ECN target to work around ECN blackholes.
>   
Thanks for the tip. It is appreciated.

The band aid solution that Ori and company found was
simply to patch the local copy of the kernel used but being that sitting
on a bunch of "private" patches seems like a lose-lose situation (there
is a term you don't hear much when talking to MBAs :-) I'm now trying
to get it mainlined for them.


Thanks,
Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

