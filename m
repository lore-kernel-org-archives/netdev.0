From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] ip.7: Improve explanation about calling listen or connect
Date: Sun, 10 Feb 2013 03:00:03 +0100
Message-ID: <CAKgNAkjq3xwO7ZDH5twZdW-Onbwoim5asETPV-Zs6x73twSd7g@mail.gmail.com>
References: <1336566636-14713-1-git-send-email-fbl@redhat.com>
 <4FBF66D8.7060007@redhat.com> <20120606114426.0595fbac@asterix.rh>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Peter Schiffer <pschiffe@redhat.com>, linux-man@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:48562 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760926Ab3BJCAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 21:00:24 -0500
In-Reply-To: <20120606114426.0595fbac@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 6, 2012 at 4:44 PM, Flavio Leitner <fbl@redhat.com> wrote:
>
> Hi,
>
> Could someone tell me what's the patch current state?
> It has been a month already with no feedback.
> thanks,
> fbl

Following up, long after the fact.

Flavio, I had no time pack then to review this patch... One problem
is, you never gave any rationle for the change ("Improve explanation
of..." is not a rationale -- I need to know *why* you think the
changes are needed.)

Thanks,

Michael


> On Fri, 25 May 2012 13:02:48 +0200
> Peter Schiffer <pschiffe@redhat.com> wrote:
>
>> Hi Michael,
>>
>> do you have any comments for this update? Or do you need some supporting
>> info?
>>
>> peter
>>
>> On 05/09/2012 02:30 PM, Flavio Leitner wrote:
>> > Signed-off-by: Flavio Leitner<fbl@redhat.com>
>> > ---
>> >   man7/ip.7 |   15 +++++++++------
>> >   1 files changed, 9 insertions(+), 6 deletions(-)
>> >
>> > diff --git a/man7/ip.7 b/man7/ip.7
>> > index 9f560df..84fe32d 100644
>> > --- a/man7/ip.7
>> > +++ b/man7/ip.7
>> > @@ -69,12 +69,11 @@ For
>> >   you may specify a valid IANA IP protocol defined in
>> >   RFC\ 1700 assigned numbers.
>> >   .PP
>> > -.\" FIXME ip current does an autobind in listen, but I'm not sure
>> > -.\" if that should be documented.
>> >   When a process wants to receive new incoming packets or connections, it
>> >   should bind a socket to a local interface address using
>> >   .BR bind (2).
>> > -Only one IP socket may be bound to any given local (address, port) pair.
>> > +In this case, only one IP socket may be bound to any given local
>> > +(address, port) pair.
>> >   When
>> >   .B INADDR_ANY
>> >   is specified in the bind call, the socket will be bound to
>> > @@ -82,10 +81,14 @@ is specified in the bind call, the socket will be bound to
>> >   local interfaces.
>> >   When
>> >   .BR listen (2)
>> > -or
>> > +is called on an unbound socket, the socket is automatically bound
>> > +to a random free port with the local address set to
>> > +.BR INADDR_ANY .
>> > +When
>> >   .BR connect (2)
>> > -are called on an unbound socket, it is automatically bound to a
>> > -random free port with the local address set to
>> > +is called on an unbound socket, the socket is automatically bound
>> > +to a random free port or an usable shared port with the local address
>> > +set to
>> >   .BR INADDR_ANY .
>> >
>> >   A TCP local socket address that has been bound is unavailable for
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
