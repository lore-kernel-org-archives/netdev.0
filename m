From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Linux stack performance drop (TCP and UDP) in 3.10 kernel
 in routed scenario
Date: Wed, 04 Jun 2014 09:34:26 -0700
Message-ID: <1401899666.3645.255.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	 <CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	 <1401885281.3645.245.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJMXqXaqXG03e+OHr0aMh9x_N4BzBVWTkQLKgNVvq-QmDaX5Ng@mail.gmail.com>
	 <1401893993.3645.253.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.ne
To: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:37290 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbaFDQe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 12:34:27 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so7195525pbb.22
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 09:34:27 -0700 (PDT)
In-Reply-To: <1401893993.3645.253.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-04 at 07:59 -0700, Eric Dumazet wrote:

> Its yet not clear why a router has to checksum TCP packets.
> 
> Maybe a conntracking requirement...


Right... you can tweak nf_conntrack_checksum
