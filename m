From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Tue, 22 Mar 2011 16:26:34 -0400
Message-ID: <20110322202634.GA11864@gospo.rdu.redhat.com>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932083Ab1CVU0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 16:26:42 -0400
Content-Disposition: inline
In-Reply-To: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 01:38:12PM +0100, Jiri Pirko wrote:
> This prevents possible race between bond_enslave and bond_handle_fram=
e
> as reported by Nicolas by moving rx_handler register/unregister.
> slave->bond is added to hold pointer to master bonding sructure. That
> way dev->master is no longer used in bond_handler_frame.
> Also, this removes "BUG: scheduling while atomic" message
>=20
> Reported-by: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

This seems reasonable.  I presume Nicolas was able to test it and verif=
y
it resolved his issue?


