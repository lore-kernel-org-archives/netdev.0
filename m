From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2008-11-06-13-44 uploaded (smc-ultra)
Date: Wed, 12 Nov 2008 14:50:29 -0800
Message-ID: <20081112145029.8034a6f5.akpm@linux-foundation.org>
References: <200811062144.mA6LiWj8004200@imap1.linux-foundation.org>
	<20081108100911.e475ff0f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	p_gortmaker@yahoo.com,
	=?ISO-8859-1?Q?M=E1rton_N=E9meth?= <nm127@freemail.hu>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39671 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755674AbYKLWus convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 17:50:48 -0500
In-Reply-To: <20081108100911.e475ff0f.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Nov 2008 10:09:11 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Thu, 06 Nov 2008 13:44:32 -0800 akpm@linux-foundation.org wrote:
>=20
> > The mm-of-the-moment snapshot 2008-11-06-13-44 has been uploaded to
> >=20
> >    http://userweb.kernel.org/~akpm/mmotm/
> >=20
> > It contains the following patches against 2.6.28-rc3:
>=20
>=20
> mmotm-2008-1106-1344/drivers/net/smc-ultra.c: In function 'ultra_prob=
e1':
> mmotm-2008-1106-1344/drivers/net/smc-ultra.c:254: error: 'mac' undecl=
ared (first use in this function)
>=20

Caused by M=E1rton's smc-ultra-get-rid-of-eth%d-message.patch.  Someone
went and removed `mac' from linux-next, and that patch depended upon it=
=2E

M=E1rton, I'll drop the patch.  Please redo and resend (against linux-n=
ext),
thanks.
