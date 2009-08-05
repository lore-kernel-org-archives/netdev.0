From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] net: implement a SO_PROTOCOL getsockoption
Date: Wed, 5 Aug 2009 10:45:29 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0908051042180.28374@fbirervta.pbzchgretzou.qr>
References: <1249406909-24161-1-git-send-email-jengelh@medozas.de> <200908050935.03272.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:57990 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933342AbZHEIpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 04:45:30 -0400
In-Reply-To: <200908050935.03272.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2009-08-05 08:35, R=C3=A9mi Denis-Courmont wrote:

>On Tuesday 04 August 2009 20:28:28 ext Jan Engelhardt wrote:
>> Similar to SO_TYPE returning the socket type, SO_PROTOCOL allows to
>> retrieve the protocol used with a given socket.
>
>You can easily infer the protocol family from the address family from=20
>getsockname().

As far as I remember, what you can get from getsockname is the
domain type (AF_*/PF_*) through struct sockaddr->sa_family.
Did you mean that?

Though SO_PROTOCOL and SO_DOMAIN go nicely along with SO_TYPE.
