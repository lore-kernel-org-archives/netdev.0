From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 14:29:18 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808271427040.3610@t2.domain.actdsltmp>
References: <bug-459782-176318@bugzilla.redhat.com>
 <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
 <20080826163719.GA25066@redhat.com> <87zlmyr5nz.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33468 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986AbYH0Vat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 17:30:49 -0400
In-Reply-To: <87zlmyr5nz.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008, Andi Kleen wrote:
> On a 2GB Core2 system here I see a time cat /proc/net/tcp > /dev/null
> constently dropping from 0.44s to 0.4-0.8s system time with this change.
> This is with mostly empty hash tables.

Umm, 0.4 to 0.8 seconds is on average _slower_ than 0.44 seconds.  Did you
mean .04 to .08?
