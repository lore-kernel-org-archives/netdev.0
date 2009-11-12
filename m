From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Thu, 12 Nov 2009 11:38:36 +0000
Message-ID: <20091112113836.GA7963@ff.dom.local>
References: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752918AbZKLLil@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-2009 23:48, Caleb Cushing wrote:
> On Wed, Nov 11, 2009 at 5:05 PM, Frans Pop <elendil@planet.nl> wrote:
>> On Wednesday 11 November 2009, Andi Kleen wrote:
>>> Caleb Cushing <xenoterracide@gmail.com> writes:
>>>>> I'm attaching the bisection log and a 'good' dmesg output.
>>>>>
>>>>> c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9 is the first bad commit
>>> Just gives fatal: bad object c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376=
a9
>>> here on a standard Linus linux-2.6 tree.
>> Looks to be a commit from a stable update:
>>
>> commit c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9
>> Author: Alan Stern <stern@rowland.harvard.edu>
>> Date: =C2  Tue Sep 1 11:38:34 2009 -0400
>>
>> =C2  =C2 usb-serial: change referencing of port and serial structure=
s
>>
>> =C2  =C2 commit 41bd34ddd7aa46dbc03b5bb33896e0fa8100fe7b upstream.
>>
>> Cheers,
>> FJP
>>
>=20
> yeah it is. it's from greg kroah-hartman's tree.

Could you answer the previous question too:

On 11-11-2009 22:47, Andi Kleen wrote:
=2E..
> It might be also useful if you could describe what kind
> of network devices you use and how you determine
> the packet loss.

Btw, you didn't send the stats you compared, and your wireshark dump
doesn't show anything wrong either.

Jarek P.
