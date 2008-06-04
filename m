From: David Miller <davem@davemloft.net>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 04 Jun 2008 14:55:22 -0700 (PDT)
Message-ID: <20080604.145522.118061703.davem@davemloft.net>
References: <20080604072311.GA32491@elte.hu>
	<20080604.112426.62778239.davem@davemloft.net>
	<Pine.LNX.4.64.0806042202030.6328@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, peterz@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rjw@sisk.pl, akpm@linux-foundation.org,
	johnpol@2ka.mipt.ru, mcmanus@ducksong.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55079
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751934AbYFDVzX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 17:55:23 -0400
In-Reply-To: <Pine.LNX.4.64.0806042202030.6328@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 4 Jun 2008 23:56:34 +0300 (EEST)

> Do you know if TCP ever needs to lock the child sk again (after creat=
ing=20
> it and it has started to live on its own) from a context that has alr=
eady=20
> locked the listen_sk (it could deadlock after this change)?

I don't know, and since I'm getting back onto an airplane again tomorro=
w
morning I'm the last person who is likely do be able to do an audit
of these cases for you :-)
