From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Fri, 27 Feb 2009 19:56:26 +0100
Message-ID: <49A8375A.6000006@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <alpine.DEB.1.10.0902271340320.9381@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49080 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757134AbZB0S4k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 13:56:40 -0500
In-Reply-To: <alpine.DEB.1.10.0902271340320.9381@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Fri, 30 Jan 2009, Eric Dumazet wrote:
>=20
>> 2.6.29-rc contains UDP receive improvements (lockless)
>>
>> Problem is multicast handling was not yet updated, but could be :)
>=20
> When will that happen?
>=20

When proven necessary :)

Kenny problem is about scheduling storm. The extra spin_lock() in UDP=20
multicast receive is not a problem.


