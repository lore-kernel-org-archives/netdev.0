From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 14:34:46 -0800
Message-ID: <45662206.1070104@redhat.com>
References: <11641265982190@2ka.mipt.ru> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com> <200611232249.56886.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:13487 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S934198AbWKWWfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 17:35:44 -0500
To: Hans Henrik Happe <hhh@imada.sdu.dk>
In-Reply-To: <200611232249.56886.hhh@imada.sdu.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hans Henrik Happe wrote:
> I don't know if this falls under the simplification, but wouldn't the=
re be a=20
> race when reading/copying the event data? I guess this could be solve=
d with=20
> an extra user index.=20

That's what I said, reading the value from the ring buffer structure's=20
head would be racy.  All this can only work for single threaded code.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
