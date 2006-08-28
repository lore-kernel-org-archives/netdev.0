From: "Jari Sundell" <sundell.software@gmail.com>
Subject: Re: [take14 0/3] kevent: Generic event handling mechanism.
Date: Mon, 28 Aug 2006 13:47:50 +0200
Message-ID: <b3f268590608280447s793f79fu8e6086cde1db8daf@mail.gmail.com>
References: <11564996832717@2ka.mipt.ru> <44F208A5.4050308@redhat.com>
	 <1156733977.2358.31.camel@entropy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ulrich Drepper" <drepper@redhat.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	"Zach Brown" <zach.brown@oracle.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	"Chase Venters" <chase.venters@clientec.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964832AbWH1Lrw@vger.kernel.org>
To: "Nicholas Miell" <nmiell@comcast.net>
In-Reply-To: <1156733977.2358.31.camel@entropy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/28/06, Nicholas Miell <nmiell@comcast.net> wrote:
> Also complicated is the case where waiting threads have different
> priorities, different timeouts, and different minimum event counts --
> how do you decide which thread gets events first? What if the decisions
> are different depending on whether you want to maximize throughput or
> interactivity?

BTW, what is the intended use of the min event count parameter? The
obvious reason I can see, avoiding waking up a thread too often with
few queued events, would imo be handled cleaner by just passing a
parameter telling the kernel to try to queue more events.

With a min event count you'd have to use a rather low timeout to
ensure that events get handled within a resonable time.

Rakshasa
