From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Question about netns & AF_UNIX
Date: Mon, 31 May 2010 11:19:52 +0200
Message-ID: <AANLkTim208jFNjlPelRnt849s3isVlyrtSXcLrUzIsZX@mail.gmail.com>
References: <AANLkTikBuXfzS-UIL7bDMvfpL5lx9gMqHTpGg-jrm5Zv@mail.gmail.com>
	<87d3whb4jr.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48533 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889Ab0EaJTz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 05:19:55 -0400
Received: by vws9 with SMTP id 9so467246vws.19
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 02:19:52 -0700 (PDT)
In-Reply-To: <87d3whb4jr.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, May 27, 2010 at 20:08, Dan Smith <danms@us.ibm.com> wrote:

> If you are in different network namespaces, the binding of UNIX
> sockets is also kept separate. =A0Even though the filesystem is share=
d,
> this seems to make the most sense to me.

To me it was the opposite, I thought natural that UNIX sockets would
continue to work, at least when they are bound to a filesystem entry.
Also it is a nice and clean way to communicate across namespaces
without assuming lots of things about the network configuration.

>=A0Named pipes on the
> filesystem would still be shared, by the way.

Yes, today I've tried with named pipes and worked. It's just that they
aren't as nice as UNIX sockets :)

Thanks.



--=20
Mart=EDn Ferrari
