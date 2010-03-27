From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 13:26:42 +0100
Message-ID: <20100327122642.GA5165@electric-eye.fr.zoreil.com>
References: <4BADDDB7.4010005@iki.fi>
 <20100327114059.GA3432@electric-eye.fr.zoreil.com>
 <4BADF01E.9090906@iki.fi>
 <20100327120358.GA5114@electric-eye.fr.zoreil.com>
 <4BADF738.2060600@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:42889 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753019Ab0C0M1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 08:27:11 -0400
Content-Disposition: inline
In-Reply-To: <4BADF738.2060600@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s <timo.teras@iki.fi> :
[...]
> It seems that adding single printk between writing MAC0 and MAC4 fixe=
s it.
> I guess it needs a bit of delay between the writes or something.

Can you test with a single RTL_R32 after each MACx write ?

--=20
Ueimor
