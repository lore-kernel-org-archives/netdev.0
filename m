From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/17] batman-adv: statically print gateway table header
Date: Fri, 01 Jul 2016 10:19:26 -0700
Message-ID: <1467393566.21157.10.camel@perches.com>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
	 <1467378549-9646-3-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:53002 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752450AbcGARTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 13:19:31 -0400
In-Reply-To: <1467378549-9646-3-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-01 at 15:08 +0200, Simon Wunderlich wrote:
> To make it easier to search through the code it is better to print st=
atic
> strings directly instead of using format strings printing constants.

It's also generally smaller object code and faster at runtime.

$ size net/batman-adv/gateway_client.o*
=A0=A0=A0text	=A0=A0=A0data	=A0=A0=A0=A0bss	=A0=A0=A0=A0dec	=A0=A0=A0=A0=
hex	filename
=A0=A0=A04898	=A0=A0=A0=A0=A0=A01	=A0=A0=A0=A0=A0=A00	=A0=A0=A04899	=A0=
=A0=A01323	net/batman-adv/gateway_client.o.new
=A0=A0=A04951	=A0=A0=A0=A0=A0=A01	=A0=A0=A0=A0=A0=A00	=A0=A0=A04952	=A0=
=A0=A01358	net/batman-adv/gateway_client.o.old
