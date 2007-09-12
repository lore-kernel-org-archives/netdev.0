From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: skb configured but can't get data allocated
Date: Wed, 12 Sep 2007 16:12:37 -0400
Message-ID: <46E84835.1040206@hp.com>
References: <200709121731456120c5e4ad@mail.smumn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernelnewbies@nl.linux.org
To: DHAJOGLO <DHAJOGLO@smumn.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:35709 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbXILUM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 16:12:59 -0400
In-Reply-To: <200709121731456120c5e4ad@mail.smumn.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You may want to read this page:
http://vger.kernel.org/~davem/skb.html

You will then see you problem.

Essentially, you are writing your data into an
area that is never sent.

What you are end up is this:

---------------------------------------------
| your data| space | ll-header | IPv4 header|
---------------------------------------------

-vlad
