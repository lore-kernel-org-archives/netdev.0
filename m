From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 25 Feb 2008 14:02:55 +0000
Message-ID: <20080225140255.GA5062@ff.dom.local>
References: <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local> <47BD4A34.7070606@katalix.com> <20080221120829.GB12944@ff.dom.local> <47BDB030.1050105@gmail.com> <47C2B266.8070604@katalix.com> <20080225130508.GB4733@ff.dom.local> <20080225133948.GC4733@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:35760 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbYBYOB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 09:01:56 -0500
Received: by ti-out-0910.google.com with SMTP id 28so868440tif.23
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 06:01:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080225133948.GC4733@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 01:39:48PM +0000, Jarek Poplawski wrote:
...
> Maybe, it's better to
> analyze yet if it's really so hard to eliminate taking this lock
> on the xmit path?

BTW, I'm not sure if it helps, but this matters only for the sockets
which could be used (and locked) outside of pppol2tp code (so before
pppol2tp code is called).

Jarek P.
