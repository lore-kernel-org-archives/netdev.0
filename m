From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH 2/2] cdc-phonet: autoconfigure Phonet address
Date: Wed, 09 Sep 2009 12:28:14 +0200
Message-ID: <1f7692749ea7722ba7f7f4ff9f86acd2@chewa.net>
References: <1252490406-27951-1-git-send-email-remi@remlab.net> <1252490406-27951-2-git-send-email-remi@remlab.net> <1252491850.8931.28.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36739 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbZIIK2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 06:28:12 -0400
In-Reply-To: <1252491850.8931.28.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 09 Sep 2009 12:24:10 +0200, Marcel Holtmann <marcel@holtmann.or=
g>=0D
wrote:=0D
> am I understanding this correctly, that even for the USB ones we stil=
l=0D
> have to execute that ioctl() and can not just auto configure them all=
=0D
> the time? For the USB ones, I would expect to should plug them in and=
=0D
> they are getting configured right away.=0D
=0D
The other patch makes the stack use the ioctl() internally.=0D
But now I see that I forgot some debug statement :(=0D
=0D
Still, something needs to ifconfig up/ip link set up.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

