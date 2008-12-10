From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: improve GPRS variable names
Date: Wed, 10 Dec 2008 15:14:56 +0200
Message-ID: <200812101514.56827.remi.denis-courmont@nokia.com>
References: <20081208.034533.97506116.davem@davemloft.net> <1228808759-8016-1-git-send-email-remi.denis-courmont@nokia.com> <20081209.152911.101587849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "ext David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:41360 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbYLJNPL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 08:15:11 -0500
In-Reply-To: <20081209.152911.101587849.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 December 2008 01:29:11 ext David Miller, you wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Date: Tue,  9 Dec 2008 09:45:59 +0200
>
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
>
> Since this depends upon the buggy refcount change, I'm
> tossing this and will wait for an updated version once
> everything is sorted out.

Unfortunately, I don't think there is a way around this dependency.

I believe there is a -theoretical- race condition between the deferred =
work,=20
and the device unregistering, but I could not produce it this far. The =
fixed=20
patches follow.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
