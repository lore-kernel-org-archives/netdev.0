From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 21 Nov 2006 10:09:15 +0100
Message-ID: <200611211009.17417.netdev@axxeo.de>
References: <11630606361046@2ka.mipt.ru> <45622228.80803@garzik.org> <456223AC.5080400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:63892 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1030768AbWKUJKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 04:10:19 -0500
To: Ulrich Drepper <drepper@redhat.com>
In-Reply-To: <456223AC.5080400@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Ulrich Drepper schrieb:
> Jeff Garzik wrote:
> > I think we have lived with relative timeouts for so long, it would be 
> > unusual to change now.  select(2), poll(2), epoll_wait(2) all take 
> > relative timeouts.
> 
> I'm not talking about always using absolute timeouts.
> 
> I'm saying the timeout parameter should be a struct timespec* and then 
> the flags word could have a flag meaning "this is an absolute timeout". 
>   I.e., enable both uses,, even make relative timeouts the default. 
> This is what the modern POSIX interfaces do, too, see clock_nanosleep.

I agree here. And while you are at it: Have it say "not before" vs. "not after".

<rant>
And if you call "absolute timeout" an "alarm" or "deadline" everyone will agree, 
that this is useful.

Timeout means "I ran OUT of TIME to do it" and this is by definition relative
to a starting point. A "deadline" is an absolute point in (wall) time where sth.
has to be ready and an "alarm" is an absolute point in (wall) time where sth.
is triggered (e.g. a bell rings on your "ALARM clock").

I don't know which person established that non-sense nomenclature about relative
and absolute timouts.
</rant>

Regards

Ingo Oeser
