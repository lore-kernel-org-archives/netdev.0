From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.23-rc8-mm2 - tcp_fastretrans_alert() WARNING
Date: Wed, 3 Oct 2007 00:48:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710022358530.26398@kivilampi-30.cs.helsinki.fi>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
 <46FD20F0.3050909@fr.ibm.com> <Pine.LNX.4.64.0709282143020.6013@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0709291532200.6776@kivilampi-30.cs.helsinki.fi>
 <46FE6751.3050205@free.fr> <Pine.LNX.4.64.0709292333480.8339@kivilampi-30.cs.helsinki.fi>
 <4700BD57.1090404@free.fr> <Pine.LNX.4.64.0710021310530.27745@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0710022303510.26398@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1048210765-1191359832=:26398"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40879 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbXJBVsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:48:24 -0400
In-Reply-To: <Pine.LNX.4.64.0710022303510.26398@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0710030047480.3995@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1048210765-1191359832=:26398
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0710030033041.26398@kivilampi-30.cs.helsinki.fi>

> On Tue, 2 Oct 2007, Ilpo Järvinen wrote:
> 
> > I'm currently out of ideas where it could come from...

Hmm, there seems to be off-by-one in tcp_retrans_try_collapse after
all, or in fact, two of them. I'll post patch for this tomorrow...


-- 
 i.
---696243703-1048210765-1191359832=:26398--
