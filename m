From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC: 2.6 patch] net/core/: possible cleanups
Date: Thu, 13 Apr 2006 14:30:28 +0200
Message-ID: <20060413123028.GA30574@wohnheim.fh-wedel.de>
References: <20060413115828.GD8171@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:59545 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S964902AbWDMMdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:33:39 -0400
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060413115828.GD8171@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 April 2006 13:58:28 +0200, Adrian Bunk wrote:
>=20
> - make the following trivial wrapper function a static inline:
>   - neighbour.c: neigh_parms_destroy()

Am I missing something or is there just a single caller?  In that
case, neigh_parms_put() could call kfree() directly and
neigh_parms_destroy() is free for termination.

J=F6rn

--=20
"[One] doesn't need to know [...] how to cause a headache in order
to take an aspirin."
-- Scott Culp, Manager of the Microsoft Security Response Center, 2001
