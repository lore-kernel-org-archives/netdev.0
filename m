From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net] Phonet: hold GPRS device while cleaning up
Date: Tue, 9 Dec 2008 17:03:41 +0200
Message-ID: <200812091703.41339.remi.denis-courmont@nokia.com>
References: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com> <20081209.001511.107468007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:44404 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbYLIPFf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 10:05:35 -0500
In-Reply-To: <20081209.001511.107468007.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 December 2008 10:15:11 ext David Miller, you wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Date: Mon,  8 Dec 2008 12:09:25 +0200
>
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
>
> Applied.

Uho :( I ended up not testing what I thought I was :-$ This patch deadl=
ocks=20
unregister_netdev(), since that waits for the refcount to drop to zero.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
