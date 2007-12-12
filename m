From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking GSOed skbs when SACKed one-by-one
Date: Tue, 11 Dec 2007 16:14:36 -0800
Message-ID: <aa7d2c6d0712111614k2832f51axa8bc9736ac7ec796@mail.gmail.com>
References: <Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
	 <20071207.173201.95379610.davem@davemloft.net>
	 <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
	 <20071211.043239.224938181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:1745 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbXLLAOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 19:14:38 -0500
Received: by py-out-1112.google.com with SMTP id u77so39602pyb.16
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 16:14:37 -0800 (PST)
In-Reply-To: <20071211.043239.224938181.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings all,

On 11/12/2007, David Miller <davem@davemloft.net> wrote:
>
> we should
> get it right as it might have network driver interface implications.

If you're redoing the driver interface, could I put in a request for
packet time-stamping at a lower level?

This thread started because TCP processing interferes with RTT
estimation.  This problem would be eliminated if time-stamping were
done as soon as the packet comes off the NIC.

$0.02
Lachlan

-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
