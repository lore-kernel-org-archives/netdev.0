From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Fix fackets corruption during transitional state
Date: Thu, 1 May 2008 23:37:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805012335110.29396@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0805012328570.29396@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Furniss <lists@andyfurniss.entadsl.com>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Netdev <netdev@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Arjan van de Ven <arjan@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56135 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310AbYEAUh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 16:37:26 -0400
In-Reply-To: <Pine.LNX.4.64.0805012328570.29396@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0805012335112.29396@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doh, on the second though, this won't fix anything (!tp->sacked_out is 
already checked in tcp_adjust_fackets_out() :-/). Please don't apply.

--
 i.
