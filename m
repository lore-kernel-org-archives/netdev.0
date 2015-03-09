From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tipc: fix inconsistent signal handling
 regression
Date: Mon, 09 Mar 2015 15:42:51 -0400 (EDT)
Message-ID: <20150309.154251.1600416012786968737.davem@redhat.com>
References: <1425894222-22650-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, laszlo.benedek@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503AbbCITnH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:43:07 -0400
In-Reply-To: <1425894222-22650-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: <erik.hugne@ericsson.com>
Date: Mon, 9 Mar 2015 10:43:42 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
>=20
> Commit 9bbb4ecc6819 ("tipc: standardize recvmsg routine") changed
> the sleep/wakeup behaviour for sockets entering recv() or accept().
> In this process the order of reporting -EAGAIN/-EINTR was reversed.
> This caused problems with wrong errno being reported back if the
> timeout expires. The same problem happens if the socket is
> nonblocking and recv()/accept() is called when the process have
> pending signals. If there is no pending data read or connections to
> accept, -EINTR will be returned instead of -EAGAIN.
>=20
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reported-by L=E1szl=F3 Benedek <laszlo.benedek@ericsson.com>

Applied, thanks.
