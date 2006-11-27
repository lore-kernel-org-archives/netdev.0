From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Mon, 27 Nov 2006 11:23:25 -0800
Message-ID: <456B3B2D.9040302@redhat.com>
References: <11641265982190@2ka.mipt.ru> <4564E2AB.1020202@redhat.com> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com> <20061124114614.GA32545@2ka.mipt.ru> <45671E16.6060005@redhat.com> <20061124164916.GA4012@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37848 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1758529AbWK0T3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 14:29:34 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124164916.GA4012@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:

> That index is provided by kernel for userspace so that userspace coul=
d
> determine where indexes are - of course userspace can maintain it
> itself, but it can also use provided by kernel.

Indeed.  That's what I said.  But I also pointed out that the field is=20
only useful in simple minded programs and certainly not in the wrappers=
=20
the runtime (glibc) will provide.

As you said yourself, there is no real need for the value being there,=20
userland can keep track of it by itself.  So, let's reduce the interfac=
e.


> I do not care actually about that index, but as you have probably not=
iced,=20
> there was such an interface already, and I changed it. So, this will =
be the=20
> last change of the interface. You think it should not be exported -
> fine, it will not be.

Thanks.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
