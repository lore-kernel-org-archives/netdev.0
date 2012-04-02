From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 02 Apr 2012 17:38:18 -0400 (EDT)
Message-ID: <20120402.173818.1786343249710498137.davem@davemloft.net>
References: <1333398660-11552-1-git-send-email-levinsasha928@gmail.com>
	<201204022200.41351.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab2DBVjb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 17:39:31 -0400
In-Reply-To: <201204022200.41351.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Mon, 2 Apr 2012 22:00:40 +0300

> Le lundi 2 avril 2012 23:31:00 Sasha Levin, vous avez =E9crit :
>> +	if (len > USHRT_MAX)
>> +		return -E2BIG;
>=20
> I think EMSGSIZE is specified in that case.

Agreed.
