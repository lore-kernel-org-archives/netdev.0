From: David Miller <davem@davemloft.net>
Subject: Re: inet_diag_dump_icsk() change seems bogus...
Date: Sun, 02 Feb 2014 13:00:49 -0800 (PST)
Message-ID: <20140202.130049.1290685187605936835.davem@davemloft.net>
References: <20140202.004538.1011276314292086521.davem@davemloft.net>
	<CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbaBBVA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 16:00:57 -0500
In-Reply-To: <CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 2 Feb 2014 10:43:10 -0500

> That was true in 3.12 and earlier, but AFAICT since Eric's 05dbc7b
> ("tcp/dccp: remove twchain") in 3.13-rc1, there is no head->twchain,
> and instead all the connections (both tcp_sock and timewait flavor)
> are on the head->chain, so that we do need to check for timewait
> sockets. :-)

Therefore I don't need to -stable backport this change, ok makes
sense, thanks for explaining.
