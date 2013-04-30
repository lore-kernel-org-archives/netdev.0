From: David VomLehn <David.VomLehn@spacex.com>
Subject: What does socket option SO_SNDBUF mean?
Date: Mon, 29 Apr 2013 18:11:12 -0700
Message-ID: <20130430011112.GA1504@dvomlehn-z8.spacex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.spacex.net ([64.47.164.142]:32939 "EHLO mta2.spacex.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758442Ab3D3BWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 21:22:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been asked how the socket option SO_SNDBUF should be used to avoid
blocking by writing too many bytes to a socket. This amounts to asking
how to interpret the SO_SNDBUF value. After looking through the networking
code for various kernel versions, it looks like the amount of overhead
included and how it is used is variable.

So:
1.	How *should* SO_SNDBUF be interpreted?
2.	Is it appropriate to use it to avoid blocking of socket writes?
3.	Does it have other uses besides giving a very fuzzy idea of
	socket writes will block?
-- 
David VL
