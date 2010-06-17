From: Narendra Choyal <narendrachoyal@gmail.com>
Subject: Re: ftp on udp and tcp .
Date: Thu, 17 Jun 2010 08:01:35 +0530
Message-ID: <AANLkTinuDmi2e1ZIFwL9qNKv_QcjVIMr56m9QuzBeyLI@mail.gmail.com>
References: <AANLkTimz7A03_UwOcjgrixqGH9MW8i1dAH6ULfR-sS5z@mail.gmail.com>
	<1276602615.14011.464.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ratheesh k <ratheesh.ksz@gmail.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:41077 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756642Ab0FQCbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 22:31:37 -0400
In-Reply-To: <1276602615.14011.464.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP handles segmentation and bandwidth/congestion management.  It
recovers from packet loss and reordering. Recent implementations are
also quite resilient to address spoofing.  The downsides are higher
latency (potentially very high when recovering from packet loss), higher
setup cost (3-way handshake), and lack of multicast support.

UDP does none of that.  It gives you flexibility and control, but the
downside is you have to handle all of those problems yourself.

Its nice but.
Initial checking of availability for both active port & passive port.
