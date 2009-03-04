From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: some tc commands fail on 2.6.29-rc6-git5, works on 2.6.28.7
Date: Wed, 4 Mar 2009 14:09:57 +0000
Message-ID: <a5d9929e0903040609x43dbeda9h26a882897a177400@mail.gmail.com>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com>
	 <20090301165729.8e08e1d7.akpm@linux-foundation.org>
	 <49AC28FF.1040102@gmail.com>
	 <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
	 <1236135028.7883.44.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:35256 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754282AbZCDOKB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 09:10:01 -0500
In-Reply-To: <1236135028.7883.44.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Just to confirm that i also have all traffic control/shaping (QoS,
connection limits, scheduling, etc) enabled on the config i use.

Its not just the specific version of tc i posted, i tried one from
last year (october, but i didnt note the exact build) with the same
result.

Cheers,
Joao Correia
Centro de Informatica
Universidade da Beira Interior
Portugal

On Wed, Mar 4, 2009 at 2:50 AM, John Dykstra <john.dykstra1@gmail.com> =
wrote:
> On Tue, 2009-03-03 at 23:10 +0000, Joao Correia wrote:
>> I have confirmed again that the exact same commands (as on the
>> original message), work flawlessly on 2.6.28.7 without a hitch, and,
>> AFAIK, work as intended. I have also tried the latest 2.6.29-rc6-git=
7
>> and it still fails like on git6.
>
> I have also reproduced this on Linus' latest 2.6.29-rc6 tree, using t=
c
> version iproute2-ss071016 and a kernel config with all traffic contro=
l
> features enabled.
>
> The error reported by tc comes from the kernel-level check added by:
>
> =A0 =A0 =A0 =A0commit c1b56878fb68e9c14070939ea4537ad4db79ffae
> =A0 =A0 =A0 =A0Author: Stephen Hemminger <shemminger@vyatta.com>
> =A0 =A0 =A0 =A0Date: =A0 Tue Nov 25 21:14:06 2008 -0800
>
> =A0 =A0 =A0 =A0tc: policing requires a rate estimator
>
> =A0 =A0Found that while trying average rate policing, it was possible=
 to
> =A0 =A0request average rate policing without a rate estimator. This r=
esults
> =A0 =A0in no policing which is harmless but incorrect.
>
> =A0 =A0Since policing could be setup in two steps, need to check
> =A0 =A0in the kernel.
>
> =A0 =A0Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> I got the same error when using the tc version iproute2-ss090115 buil=
t
> this evening from the public git repository.
>
> =A0-- John
>
>
