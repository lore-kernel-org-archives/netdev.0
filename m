From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Wed, 14 May 2014 13:08:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: 'Veaceslav Falico' <vfalico@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43807 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754683AbaENNI2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 09:08:28 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11355-10 for <netdev@vger.kernel.org>;
 Wed, 14 May 2014 14:08:19 +0100 (BST)
In-Reply-To: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico
> Hi,
> 
> That's a trivial patchset that tries to unify the macro usage of bonding
> modes. I've split it into two approaches - either BOND_*, which takes
> bonding struct as a param, or MODE_*, which takes the mode itself. Also,
> introduce BOND_MODE(bond) instead of ugly bond->params.mode.

I'm not sure these are improvements....

I thought that netdev (in particular) preferred static inline functions
to #defines - and especially #defines that expand their argument(s)
more than once.

IMHO Simple access functions are just a PITA when reading code since
they cause the reader to go off somewhere and look up the definition.

	David
