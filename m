From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Fri, 6 Jan 2012 19:11:32 +0100
Message-ID: <4F073954.7040001@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <4EA5738B.8080008@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arvid Brodin <arvid.brodin@enea.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:27792 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758875Ab2AFSLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 13:11:49 -0500
In-Reply-To: <4EA5738B.8080008@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arvid Brodin wrote:
>> On Tue, 11 Oct 2011 20:25:08 +0200
>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>>
>>> Hi,
>>>
>>> I want to add support for HSR ("High-availability Seamless Redundancy",
>>> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
>>> ports and are connected in a ring. All new Ethernet packets are sent on both
>>> ports (or passed through if the current unit is not the originating unit). The
>>> same packet is never passed twice. Non-HSR units are not allowed in the ring.
>>>
>>> This gives instant, reconfiguration-free failover.
>>>
*snip*
> 
> I need to do two things:
> 
> 1) Bind two network interfaces into one (say, eth0 & eth1 => hsr0). Frames sent on
>    hsr0 should get an HSR tag (including the correct EtherType) and go out on both
>    eth0 and eth1.
> 
> 2) Ingress frames on eth0 & eth1, with EtherType 0x88fb, should be captured and 
>    handled specially (either received on hsr0 or forwarded to the other bound 
>    physical interface).
> 

I'm slowly getting there! :)

But what is net_device->header_ops->rebuild supposed to do?

Thanks,
Arvid Brodin
Enea Services Stockholm AB
