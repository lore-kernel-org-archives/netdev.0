From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Thu, 11 Apr 2013 13:52:23 -0400
Message-ID: <20130411175223.GG8986@neilslaptop.think-freely.org>
References: <5166BDAA.3000603@acm.org>
 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <5166F35B.1040200@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57972 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964931Ab3DKRwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:52:35 -0400
Content-Disposition: inline
In-Reply-To: <5166F35B.1040200@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 07:31:07PM +0200, Bart Van Assche wrote:
> On 04/11/13 17:18, Neil Horman wrote:
> >Bart, this patch should fix your problem.  Could you please test it =
and confirm?
>=20
> The fails to build on my setup after having applied that patch:
>=20
> kernel/mutex.c: In function =E2=80=98__mutex_trylock_slowpath=E2=80=99=
:
> kernel/mutex.c:446:2: error: implicit declaration of function
> =E2=80=98spin_unlock_mutex_raw=E2=80=99 [-Werror=3Dimplicit-function-=
declaration]
>=20
Strage, not sure why, although I didn't explicitly test it myself.  I'l=
l take a
look this evening and fix it up for you.
Neil

> Bart.
>=20
