From: =?iso-8859-1?Q?Lu=EDs?= Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH v2] rds: prevent dereference of a NULL device in
 rds_iw_laddr_check
Date: Fri, 4 Apr 2014 15:31:36 +0100
Message-ID: <20140404143136.GA2593@hercules>
References: <1396139975-5314-1-git-send-email-sasha.levin@oracle.com>
 <20140331.162607.153228065356865845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sasha.levin@oracle.com, chien.yen@oracle.com,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140331.162607.153228065356865845.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Mar 31, 2014 at 04:26:07PM -0400, David Miller wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Sat, 29 Mar 2014 20:39:35 -0400
>=20
> > Binding might result in a NULL device which is later dereferenced
> > without checking.
> >=20
> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>=20
> Applied, thanks Sasha.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This is very similar to c2349758acf1874e4c2b93fe41d072336f1a31d0 ("rds:
prevent dereference of a NULL device"), which you've queued for stable.

Could you please queue this one for stable as well?  (Looks like it eve=
n
has CVE-2014-2678 assigned to it.)

Cheers,
--
Lu=EDs
