From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: skge driver oops
Date: Sun, 23 Jul 2006 00:28:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0607230018150.22678@bizon.gios.gov.pl>
References: <BB1F4EFD574E9F409035BDA71C9612500241A2@exchange.i-bn>
 <20060526081737.5c5b422f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1966348823-1153607305=:22678"
Cc: Beschorner Daniel <Daniel.Beschorner@facton.com>,
	netdev@vger.kernel.org, "'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56963 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S1751064AbWGVW2o
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jul 2006 18:28:44 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060526081737.5c5b422f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1966348823-1153607305=:22678
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 26 May 2006, Stephen Hemminger wrote:

> Please give this a try, it rearranges the transmit buffer management,
> and may avoid issues with partial completions causing SKB reuse.

<CUT>

Plase excuse me, I overlooked this patch. Anyway, it seems that this fix=20
went into the 2.6.16 kernel, which is already on the server that caused=20
problems (http://bugzilla.kernel.org/show_bug.cgi?id=3D6142). I'll disable=
=20
my workaround (/usr/sbin/ethtool -K eth1 tx off) and let you known about=20
the results.

Thank you.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1966348823-1153607305=:22678--
