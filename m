From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] net/mlx4: use rb_entry()
Date: Sun, 22 Jan 2017 21:05:21 +0200
Message-ID: <20170122190521.GB1535@mtr-leonro.local>
References: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
 <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
 <20170122074839.GD28570@mtr-leonro.local>
 <20170122144225.lvkakc7db7fs2xpq@ThinkPad>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="cvVnyQ+4j833TQvp"
Cc: Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46254 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdAVTFV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 14:05:21 -0500
Content-Disposition: inline
In-Reply-To: <20170122144225.lvkakc7db7fs2xpq@ThinkPad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cvVnyQ+4j833TQvp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jan 22, 2017 at 10:42:25PM +0800, Geliang Tang wrote:
> On Sun, Jan 22, 2017 at 09:48:39AM +0200, Leon Romanovsky wrote:
> > On Fri, Jan 20, 2017 at 10:36:57PM +0800, Geliang Tang wrote:
> > > To make the code clearer, use rb_entry() instead of container_of() to
> > > deal with rbtree.
> > >
> > > Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> > > ---
> > >  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 8 ++++----
> > >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> > I don't understand completely the rationale behind this conversion.
> > rb_entry == container_of, why do we need another name for it?
> >
>
> There are several *_entry macros which are defined in kernel data
> structures, like list_entry, hlist_entry, rb_entry, etc. Each of them is
> just another name for container_of. We use different *_entry so that we
> could identify the specific type of data structure that we are dealing
> with.

Your proposed patch doesn't support the importance of such knowledge for
rb_entry. The list_entry case is totally different, because you perform
operation on it.

Anyway, It doesn't matter.
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--cvVnyQ+4j833TQvp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliFAnEACgkQ5GN7iDZy
WKdpJA//dKh6Ice3mhvcbogtacGue9xC8TIGSdu35lbhzqnV4jrvTDgr4tyjFk6p
tpahSko6e6InFsyLZICSD+/P7qD1rR3u9DrrgDu+/1CTKD2Tq2jpehmWilJfJj/Y
5TT7dcCN5uiylme6iUVmqih1ELf5OhST6oXo1lWV+h9CrzkrpI3x37MeBodlQTAy
Deu4bpdw0ly1UA65iMA/1ef6QudW3chYBd1AXYxlvJyXmQFOeM7XQZH/QKUvD6Fc
bH3L2A8wqMpuKTVtmDnX10MhyG1khuXhy0WBjFvok036VRuZ+enpch32uBK/6VLF
ZtxmqdtT0G66kjc/buGVET+zerkjh5zSOQrO/Dl6M0/qzbCMHqSsJaXBcXBj/+9K
gi4/2yJ+7OyiuNB64cxTNBrMskvQb5esAo6ojuj/q3Qzk0oIdaNc1XNftpuMt1J4
FJNcH1pZZtDq3lbo59WrzitWACyiGHyB9WZSu8eFIReGUqBhv54vJAKL+6TqCdt+
DvO6YVVW3GeRuM/Q8b7RfriZKoyuAmrEAi4OeGaaOaTh/03Ta+1y4bHYmG5mgeJA
l8I+56kZtca52Gxk6ocQ8MOqSJkbjnhTRDfrnQyQMH1oFrpkn0YGdtXcfzn4nxcz
GLAIGBdqylkMjnBxGyEuzwZpqZL9SP+BUTZYX5ZwCvWbqolK4Bo=
=XZft
-----END PGP SIGNATURE-----

--cvVnyQ+4j833TQvp--
