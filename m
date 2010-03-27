From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 22:11:34 +0100
Message-ID: <20100327211133.GA3624@electric-eye.fr.zoreil.com>
References: <4BADDDB7.4010005@iki.fi>
 <20100327114059.GA3432@electric-eye.fr.zoreil.com>
 <4BADF01E.9090906@iki.fi>
 <20100327120358.GA5114@electric-eye.fr.zoreil.com>
 <4BADF738.2060600@iki.fi>
 <20100327122642.GA5165@electric-eye.fr.zoreil.com>
 <4BADFAE4.5040906@iki.fi>
 <4BAE6C92.2060801@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:42190 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753960Ab0C0VMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 17:12:12 -0400
Content-Disposition: inline
In-Reply-To: <4BAE6C92.2060801@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s <timo.teras@iki.fi> :
[...]
> Any ideas how to check this?

Check the datasheet of VIA's chipset for a WC control bit - there
ought to be one - and disable it.

> Or is swapping MAC0/MAC4 writes, or adding the extra read an
> acceptable fix/workaround?

swapping should reliably disable WC. It would be fine.

--=20
Ueimor
