From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Tue, 3 Oct 2006 23:10:51 -0700
Message-ID: <a36005b50610032310o13b9340cp8dc3fd2240e77c58@mail.gmail.com>
References: <115a6230591036@2ka.mipt.ru> <11587449471424@2ka.mipt.ru>
	 <20060922122207.3b716028.akpm@osdl.org>
	 <20060923042350.GA24099@2ka.mipt.ru>
	 <a36005b50610032309u2a8b5797x43e5cce2fbd1d18e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Ulrich Drepper" <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"Zach Brown" <zach.brown@oracle.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	"Chase Venters" <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:57634 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030388AbWJDGKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 02:10:53 -0400
Received: by ug-out-1314.google.com with SMTP id o38so17598ugd
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2006 23:10:52 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <a36005b50610032309u2a8b5797x43e5cce2fbd1d18e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Bah, sent too eaqrly]

On 9/22/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> The only two things missed in patchset after his suggestions are
> new POSIX-like interface, which I personally consider as very unconvenient,

This means you really do not know at all what this is about.  We
already have these interfaces.  Several of them and there will likely
be more.  These are interfaces for functionality which needs the new
event notification.  There is *NO* reason whatsoever to not make add
this extension and instead invent new interfaces to have notification
sent to the event queue.
