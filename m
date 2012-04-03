From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 02:38:13 -0400 (EDT)
Message-ID: <20120403.023813.1884403672741100061.davem@davemloft.net>
References: <201204022201.41808.remi@remlab.net>
	<20120402.174006.70116829696492189.davem@davemloft.net>
	<dc6e3bc8b96d91bd7ce44639b60cfec2@chewa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: levinsasha928@gmail.com, davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: remi@remlab.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dc6e3bc8b96d91bd7ce44639b60cfec2@chewa.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Tue, 03 Apr 2012 08:36:20 +0200

> Oh right. And Phonet devices don't support scatter/gather, so that I
> guess that would merely delay the problem.

And this lack of SG support in the drivers never materialized largely
because the phonet stack never generated such things.

So yes indeed both sides of this equation will need to be addressed.
