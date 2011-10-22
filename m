From: Dan McGee <dpmcgee@gmail.com>
Subject: Re: [PATCH] Disable TCP_DEBUG and FASTRETRANS_DEBUG by default
Date: Fri, 21 Oct 2011 20:54:09 -0500
Message-ID: <CAEik5nPciVMwOE-hC+oPP1gMEvRzbhFwAZHKNQnHEc0YOUXuWA@mail.gmail.com>
References: <1318883125-29500-1-git-send-email-dpmcgee@gmail.com>
	<20111017.175238.18474279385644215.davem@davemloft.net>
	<20111019151600.67cd99e6@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36663 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1JVByL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 21:54:11 -0400
In-Reply-To: <20111019151600.67cd99e6@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 12:16 PM, Flavio Leitner <fbl@redhat.com> wrote=
:
> On Mon, 17 Oct 2011 17:52:38 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Dan McGee <dpmcgee@gmail.com>
>> Date: Mon, 17 Oct 2011 15:25:24 -0500
>>
>> > If these are truly debug options, they should be turned off by def=
ault
>> > and can be tweaked if necessary. Fix one usage of the flag to use =
#if
>> > instead of #ifdef so defining to zero is acceptable.
>> >
>> > Signed-off-by: Dan McGee <dpmcgee@gmail.com>
>>
>> Illegal window shrinks are a serious issue, and the fact that everyo=
ne
>> will see those messages by default and sometimes report them has bee=
n
>> tremendously useful.
>>
>
> Agreed. I recently got bug report because of that message. =C2=A0It i=
s useful
> and doesn't disturbe when network is fine, so please don't remove it.
Can we kill TCP_DEBUG completely then? This is the only place it is
used, and it clearly is mislabeled if this is a "serious" and "useful"
feature.

Can anyone weigh in on FASTRETRANS_DEBUG and setting that to 0 by defau=
lt?

-Dan
