From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 22 Oct 2008 19:36:08 +0200
Message-ID: <48FF6488.8050109@gmail.com>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu> <48FF614C.7020507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:43001 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757018AbYJVRff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 13:35:35 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1480124nfc.21
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 10:35:33 -0700 (PDT)
In-Reply-To: <48FF614C.7020507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 10/22/2008 07:22 PM:

> Ferenc Wagner wrote, On 10/22/2008 05:00 PM:
> 
>> Ferenc Wagner <wferi@niif.hu> writes:
>>
>>> I expected an IP-less bridge interface to pick up no IP packets, but
>>> apparently this isn't the case: broadcast packets with destination
>>> address 255.255.255.255 are reported as martians by the 2.6.1

...

>>>   2. I tried to cut down the logs by explicit iptables drops, but
>>>      didn't succeed.  Does martian detection happen before the
>>>      netfilter rules?  (I know I can disable martian logging by
>>>      interface, but wanted finer granularity.)
> 
> 
> It's after netfilter's PREROUTING. (BTW, it's also after ingress
> qdisc where you can try some filtering.)


On the other hand, if it's a bridge, you should probably have a look
at ebtables instead of iptables.
 

Jarek P.
