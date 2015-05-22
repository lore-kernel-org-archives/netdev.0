From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] xen-netfront crash when detaching network while some
 network activity
Date: Fri, 22 May 2015 17:58:41 +0100
Message-ID: <555F6041.7000203@citrix.com>
References: <20150522114932.GC8664@mail-itl> <555F5888.4020303@citrix.com>
 <20150522164246.GE957@mail-itl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, xen-devel <xen-devel@lists.xen.org>
To: =?UTF-8?B?TWFyZWsgTWFyY3p5a293c2tpLUfDs3JlY2tp?=
	<marmarek@invisiblethingslab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:46457 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757077AbbEVQ6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 12:58:44 -0400
In-Reply-To: <20150522164246.GE957@mail-itl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/05/15 17:42, Marek Marczykowski-G=C3=B3recki wrote:
> On Fri, May 22, 2015 at 05:25:44PM +0100, David Vrabel wrote:
>> On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
>>> Hi all,
>>>
>>> I'm experiencing xen-netfront crash when doing xl network-detach wh=
ile
>>> some network activity is going on at the same time. It happens only=
 when
>>> domU has more than one vcpu. Not sure if this matters, but the back=
end
>>> is in another domU (not dom0). I'm using Xen 4.2.2. It happens on k=
ernel
>>> 3.9.4 and 4.1-rc1 as well.
>>>
>>> Steps to reproduce:
>>> 1. Start the domU with some network interface
>>> 2. Call there 'ping -f some-IP'
>>> 3. Call 'xl network-detach NAME 0'
>>
>> I tried this about 10 times without a crash.  How reproducible is it=
?
>>
>> I used a 4.1-rc4 frontend and a 4.0 backend.
>=20
> It happens every time for me... Do you have at least two vcpus in tha=
t
> domU? With one vcpu it doesn't crash. The IP for ping I've used one i=
n
> backend domU, but it shouldn't matter.
>=20
> Backend is 3.19.6 here. I don't see any changes there between rc1 and
> rc4, so stayed with rc1. With 4.1-rc1 backend it also crashes for me.

Doesn't repro for me with 4 VCPU PV or PVHVM guests.  Is your guest
kernel vanilla or does it have some qubes specific patches on top?

David
