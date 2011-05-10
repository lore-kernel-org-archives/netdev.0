From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: Bug#625914: linux-image-2.6.38-2-amd64: bridging is not interacting
 well with multicast in 2.6.38-4
Date: Tue, 10 May 2011 14:55:49 +0200
Message-ID: <4DC935D5.4020601@univ-nantes.fr>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>	 <1304995124.4065.157.camel@localhost>  <20110510043833.GG6397@morgul.net> <1305031369.4065.259.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls2.univ-nantes.fr ([193.52.101.146]:56727 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab1EJM5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 08:57:51 -0400
In-Reply-To: <1305031369.4065.259.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2011-05-09 at 21:38 -0700, Noah Meyerhans wrote:
>> On Tue, May 10, 2011 at 03:38:44AM +0100, Ben Hutchings wrote:
>>> This is pretty weird.  Debian version 2.6.38-3 has a few bridging
>>> changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like=
 they
>>> would cause this.
>> I have apparently filed the bug against the wrong version of Debian'=
s
>> kernel.  2.6.38-3 is not affected, and works as expected.  The chang=
e
>> was introduced in -4.  That may have been clear from the report itse=
lf,
>> but the report was filed against -3.  I've fixed that in the BTS.
> I gathered that, and then made the same mistake in writing the above!
> The version with the regression, 2.6.38-4, includes the changes from
> stable 2.6.38.3 and 2.6.38.4
>
> Ben.
>
>

We just hitted the very same problem yesterday, with debian too , BUT=20
with vanilla kernels (hand compiled from GIT, with a specific config).

I can confirm that 2.6.38.5 & 2.6.38.6 have this problem, but 2.6.38.3=20
works fine.

So this is not a debian specific bug as far as I can see.

Cheers,

--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr

