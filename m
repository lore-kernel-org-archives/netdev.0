From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Subject: Re: single process receives own frames due to PACKET_MMAP
Date: Wed, 08 Jan 2014 15:36:48 +0100
Message-ID: <52CD6280.3080300@aimvalley.nl>
References: <52B4465E.2090904@aimvalley.nl> <52CB34F9.6020906@aimvalley.nl> <52CBC991.8030701@redhat.com> <20140107110609.74f71979@redhat.com> <52CBFE13.8@aimvalley.nl> <20140107150938.1058b358@redhat.com> <52CC1A61.5080205@aimvalley.nl> <52CC1C94.2060808@redhat.com> <52CC2168.9060401@aimvalley.nl> <52CC23F6.1070801@redhat.com> <52CD5E37.5070104@aimvalley.nl> <52CD5FAB.60801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, uaca@alumni.uv.es
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mika.eatserver.nl ([195.20.9.75]:52620 "EHLO mika.eatserver.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755069AbaAHOiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 09:38:03 -0500
In-Reply-To: <52CD5FAB.60801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/14 15:24, Daniel Borkmann wrote:
> On 01/08/2014 03:18 PM, Norbert van Bolhuis wrote:
>
>>>> Is there a way to use one PF_PACKET socket for both TX and RX and use PACKET_MMAP ?
>>>
>>> Yep:
>>>
>>> http://thread.gmane.org/gmane.linux.network/269129/focus=269188
>>>
>>> Feel free to make a patch and add this to Documentation/networking/packet_mmap.txt
>>> I think could be useful for others as well.
>>
>>
>> Good, it all works fine now, though performance is still not as good as I'd hoped.
>
> Does your use case allow for TPACKET_V3 or for using fanout ?
>

no, unfortunately not.

Though currently our performance is limited by application/system stuff, so
at the moment it doesn't really matter.

--
Norbert
