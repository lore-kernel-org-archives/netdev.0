From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Bind fackets_out state to highest_sack more
 tightly
Date: Mon, 10 Dec 2007 14:39:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712101437080.3437@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712101426010.18529@kivilampi-30.cs.helsinki.fi>
 <20071210.043127.60066660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-769200794-1197290386=:3437"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55827 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbXLJMjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 07:39:48 -0500
In-Reply-To: <20071210.043127.60066660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-769200794-1197290386=:3437
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 10 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 10 Dec 2007 14:27:24 +0200 (EET)
> 
> > Added checks will catch most of the errors if the current
> > complex fack_count counting logic is flawed somewhere.
> > 
> > Fackets_out should always be advancable if highest_sack is too
> > because the fackets_out is nowadays accurate (and obviously it
> > must be smaller than packets_out).
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Applied to net-2.6.25, thanks!

Please get the fack_count fix as well from the mm1 thread before my 
mailbox gets filled with stacktraces :-) :
  http://marc.info/?l=linux-netdev&m=119728952018975&w=2

-- 
 i.
---696243703-769200794-1197290386=:3437--
