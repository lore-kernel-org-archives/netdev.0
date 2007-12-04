From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Tue, 4 Dec 2007 23:26:17 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712042319160.12072@kivilampi-30.cs.helsinki.fi>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
 <47559FA1.2090104@psc.edu> <Pine.LNX.4.64.0712042252450.12072@kivilampi-30.cs.helsinki.fi>
 <4755C3E9.4090609@psc.edu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-839398767-1196803366=:12072"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Matt Mathis <mathis@psc.edu>
To: John Heffner <jheffner@psc.edu>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43922 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241AbXLDV0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 16:26:18 -0500
In-Reply-To: <4755C3E9.4090609@psc.edu>
Content-ID: <Pine.LNX.4.64.0712042323502.12072@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-839398767-1196803366=:12072
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712042322501.12072@kivilampi-30.cs.helsinki.fi>

On Tue, 4 Dec 2007, John Heffner wrote:

> Ilpo Järvinen wrote:
> 
> > ...Mind if I ask another similar one, any idea why prior_ssthresh is smaller
> > (3/4 of it) than cwnd used to be (see tcp_current_ssthresh)?
> 
> Not sure on that one.  I'm not aware of any publications this is based on.

My theory is that it could relate to tcp_cwnd_restart and 
tcp_cwnd_application_limited using it and the others are just then 
accidently changed as well. Perhaps I'll have to dig once again to 
changelog history to see if there's some clue (unless Alexey shed 
some light to this)...

> Maybe Alexey knows?

Added Alexey.


-- 
 i.
---696243703-839398767-1196803366=:12072--
