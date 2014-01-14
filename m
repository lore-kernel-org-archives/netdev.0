From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [ovs-dev] [GIT net-next] Open vSwitch
Date: Tue, 14 Jan 2014 12:31:06 +0000
Message-ID: <52D52E0A.4050700@citrix.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com> <52CD657F.7080806@citrix.com> <CAEP_g=_pQpH--V+7GSrjGP2z=0TBD_37yXjzTdeKG+2OF3aRaw@mail.gmail.com> <52D42A9E.1030805@citrix.com> <52D4857C.7020902@citrix.com> <CAEP_g=8nG6AHV9Y+5=48nPhkf5Oe=mG8EiyaKSqN4omnmGhv4A@mail.gmail.com> <52D50767.6050906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@redhat.com>, Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:10652 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbaANMbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 07:31:09 -0500
In-Reply-To: <52D50767.6050906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/14 09:46, Thomas Graf wrote:
> On 01/14/2014 02:30 AM, Jesse Gross wrote:
>>> And it works. I guess the last one causing the problem. Might be an
>>> important factor, I'm using 32 bit Dom0.
>>
>> I think you're probably right. Thomas - can you take a look?
>>
>> We shouldn't be doing any zerocopy in this situation but it looks to
>> me like we don't do any padding at all, even in situations where we
>> are copying the data.
>
> I'm looking into this now. The zerocopy method should only be attempted
> if user space has announced the ability to received unaligned messages.
>
> @Zoltan: I assume you are using an unmodified OVS 1.9.3?
>
Well, there are a few changes, but none of them seems to be significant. 
Most of them are just making OVS work with our build system. Here is the 
patchqueue:

https://github.com/xenserver/openvswitch.pg/tree/master/master

See the series file for the order of the patches.

Zoli
