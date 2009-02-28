From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 0/17]: tcp & more tcp
Date: Sat, 28 Feb 2009 16:44:25 +0200
Message-ID: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbZB1Oop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The first one is the retrans leak fix for net-2.6, rest for
net-next (IMHO).

The series includes two fixes which are a result of my adventure
to measure large window loss recovery performance. I still have
some work to do in that area but the simplest in-order behaviors
now easily scales beyond 1GbE even on a low-end machine :-).

--
 i.



