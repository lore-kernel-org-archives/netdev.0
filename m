From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 08:17:30 -0800
Message-ID: <45671B1A.6010202@redhat.com>
References: <11641265982190@2ka.mipt.ru> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com> <200611232249.56886.hhh@imada.sdu.dk> <45662206.1070104@redhat.com> <20061124115004.GB32545@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Henrik Happe <hhh@imada.sdu.dk>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934961AbWKXQSQ@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124115004.GB32545@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Ulrich, why didn't you comment on previous interface, which had exact=
ly
> _one_ index exported to userspace - it is only required to add implic=
it
> uidx and (if you prefer that way) additional syscall, since in previo=
us
> interface both waiting and commit was handled by kevent_wait() with
> different parameters.

If you read my old mails you'll find that I'm pretty consistent wrt to=20
the ring buffer interface.  The old code had other problems, not the=20
missing exposure of the uidx value.

There is really not much disagreement here.  I just don't like the=20
interface unnecessarily and misleadingly large by exposing the uidx=20
value which is not useful to the userlevel code.  Just remove the=20
element and stuff it into a kernel-internal struct for the queue and=20
you're done.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
