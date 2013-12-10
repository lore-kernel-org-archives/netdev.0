From: ajay seshadri <seshajay@gmail.com>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 17:11:36 -0500
Message-ID: <CAGA2gK5CTj0ELTLnQEEZptWuRj+EGRgU4Nw5nH1CwqQigghSfg@mail.gmail.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com>
	<CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
	<20131210171248.GA23216@order.stressinduktion.org>
	<CAGA2gK5pxQXAxgffYgitWg9jUUkxnz7EEhjQZ2aSvgnWFyR9RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:50301 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab3LJWLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:11:37 -0500
Received: by mail-ig0-f173.google.com with SMTP id uq10so2864394igb.0
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 14:11:36 -0800 (PST)
In-Reply-To: <CAGA2gK5pxQXAxgffYgitWg9jUUkxnz7EEhjQZ2aSvgnWFyR9RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 2:46 PM, ajay seshadri <seshajay@gmail.com> wrote:
> On Tue, Dec 10, 2013 at 12:12 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> A cached entry will be inserted nontheless. If you don't hit the max_size
>> route entries limit I guess there could be a bug which triggers needless gc
>> invocation.
>
> I am leaning towards needless invocation of gc. At this point in time,
> I am not sure why.


Additionally,  fib6_force_start_gc() doesn't show up in TCP/IPv6 tests
when I disable TSO and am CPU bound. With TSO turned off TCP/IPv4 and
TCP/IPv6 throughputs are identical.

Thanks,
Ajay
