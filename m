From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Tue, 3 Oct 2006 23:34:02 -0700
Message-ID: <a36005b50610032334n50e66198rdfef30e4ccf545c8@mail.gmail.com>
References: <11587449471424@2ka.mipt.ru> <1158744950130@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Ulrich Drepper" <drepper@redhat.com>,
	"Andrew Morton" <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	"Zach Brown" <zach.brown@oracle.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	"Chase Venters" <chase.venters@clientec.com>,
	"Johann Borck" <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:9808 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161094AbWJDGeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 02:34:04 -0400
Received: by ug-out-1314.google.com with SMTP id o38so18793ugd
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2006 23:34:02 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <1158744950130@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/20/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> This patch includes core kevent files:
> [...]

I tried to look at the example programs before and failed.  I tried
again.  Where can I find up-to-date example code?

Some other points:

- I really would prefer not to rush all this into the upstream kernel.
 The main problem is that the ring buffer interface is a shared data
structure.  These are always tricky.  We need to find the right
combination between size (as small as possible) and supporting all the
interfaces.

- so far only the timer and aio notification is speced out.  What
about the rest?  Are we sure all aspects can be expressed?  I am not
yet.

- we need an interface to add an event from userlevel.  I.e., we need
to be able to synthesize events.  There are events (like, for instance
the async DNS functionality) which come from userlevel code.

I would very much prefer we look at the other events before setting
the data structures in stone.
