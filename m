From: =?ISO-8859-1?Q?S=E9bastien_Dugu=E9?= <sebastien.dugue@bull.net>
Subject: Re: Kernel patches enabling better POSIX AIO (Was Re: [3/4]
	kevent: AIO, aio_sendfile)
Date: Mon, 04 Sep 2006 16:37:54 +0200
Message-ID: <1157380674.3895.55.camel@frecb000686>
References: <1153982954.3887.9.camel@frecb000686>
	 <44C8DB80.6030007@us.ibm.com> <44C9029A.4090705@oracle.com>
	 <1154024943.29920.3.camel@dyn9047017100.beaverton.ibm.com>
	 <44C90987.1040200@redhat.com>
	 <1154034164.29920.22.camel@dyn9047017100.beaverton.ibm.com>
	 <1154091500.13577.14.camel@frecb000686> <44DCDE73.9030901@redhat.com>
	 <20060812182928.GA1989@in.ibm.com> <44DE27AB.7040507@redhat.com>
	 <20060812192802.GO32572@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@redhat.com>, suparna@in.ibm.com,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-aio@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58348 "EHLO
	ecfrec.frec.bull.fr") by vger.kernel.org with ESMTP
	id S1751406AbWIDOiD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 10:38:03 -0400
To: Jakub Jelinek <jakub@redhat.com>
In-Reply-To: <20060812192802.GO32572@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-08-12 at 15:28 -0400, Jakub Jelinek wrote:
> On Sat, Aug 12, 2006 at 12:10:35PM -0700, Ulrich Drepper wrote:
> > > I am wondering about that too. IIRC, the IO_NOTIFY_* constants ar=
e not
> > > part of the ABI, but only internal to the kernel implementation. =
I think
> > > Zach had suggested inferring THREAD_ID notification if the pid sp=
ecified
> > > is not zero. But, I don't see why ->sigev_notify couldn't used di=
rectly
> > > (just like the POSIX timers code does) thus doing away with the=20
> > > new constants altogether. Sebestian/Laurent, do you recall?
> >=20
> > I suggest to model the implementation after the timer code which do=
es
> > exactly what we need.
>=20
> Yeah, and if at all possible we want to use just one helper thread fo=
r
> SIGEV_THREAD notification of timers/aio/etc., so it really should beh=
ave the
> same as timer thread notification.
>=20

  That's exactly what is done in libposix-aio.

  S=E9bastien.

--=20
-----------------------------------------------------

  S=E9bastien Dugu=E9                BULL/FREC:B1-247
  phone: (+33) 476 29 77 70      Bullcom: 229-7770

  mailto:sebastien.dugue@bull.net

  Linux POSIX AIO: http://www.bullopensource.org/posix
                   http://sourceforge.net/projects/paiol

-----------------------------------------------------

