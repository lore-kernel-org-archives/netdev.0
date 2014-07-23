From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the scsi tree with the net-next tree
Date: Wed, 23 Jul 2014 16:40:49 +1000
Message-ID: <20140723164049.413272e8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/rVQsC.i=_LPMhX4.0hLTXPD"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anish Bhatt <anish@chelsio.com>, Karen Xie <kxie@chelsio.com>,
	Manoj Malviya <manojmalviya@chelsio.com>,
	Hannes Reinecke <hare@suse.de>, Christoph Hellwig <hch@lst.de>
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/rVQsC.i=_LPMhX4.0hLTXPD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi James,

Today's linux-next merge of the scsi tree got a conflict in
drivers/scsi/cxgbi/libcxgbi.h between commit fc8d0590d914 ("libcxgbi:
Add ipv6 api to driver") from the net-next tree and commit 1abf635d2f33
("scsi: use 64-bit value for 'max_luns'") from the scsi tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/scsi/cxgbi/libcxgbi.h
index 8ad73d913f02,538d7a64e138..000000000000
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@@ -708,8 -692,7 +708,8 @@@ struct cxgbi_device *cxgbi_device_regis
  void cxgbi_device_unregister(struct cxgbi_device *);
  void cxgbi_device_unregister_all(unsigned int flag);
  struct cxgbi_device *cxgbi_device_find_by_lldev(void *);
 +struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *, int=
 *);
- int cxgbi_hbas_add(struct cxgbi_device *, unsigned int, unsigned int,
+ int cxgbi_hbas_add(struct cxgbi_device *, u64, unsigned int,
  			struct scsi_host_template *,
  			struct scsi_transport_template *);
  void cxgbi_hbas_remove(struct cxgbi_device *);

--Sig_/rVQsC.i=_LPMhX4.0hLTXPD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTz1j3AAoJEMDTa8Ir7ZwV9IgQAJN5QgiB9JsR/5a3wAr4U1jq
4PZ10HfNLYl2vhNBnylSBr4VcAMKmm3fAKbeJUatuXIHt9DTr4noATcVnaXhuXJR
VFnbLYL+yG8JWdvfAbjlLsCWB9Iv1ZFsA2K7JTOfELIwz3pFrX3OTJeCyDdrK21w
p27CCDZl288VQyn9uFLYk8yc5fD2euus3XmTz5uujLwXHSwCS4LSa04kJSgn9wFo
oa4VP6q7bs1IT0Kwh7JMdWN7cGif94gCtFOrU940KPdcddgEXnTvbi6FKTXMW9VS
oEYhOvqj5yJEiNHsq/2qyPR0lwnkHl43L15UxlZ2M3/7tHUZXKsOybv0qYQHgDm1
w1oRDTlrSIbNEfOhmX/tDg/Ei5PBDxoobkBfz0BnPda6FeMYx8eg2hteSsYarphW
ivK2JnKoJcM+jLT2mjel4xRXT5bk7jpc89YfONe2K+U0C8k0dGpcq26ba4T6IEqU
n5nEoMbz/lWklhJAOdgIoyKUZpZRNtRwl4/IWBAIAyaVXENmU4m+GbOZ+OBJKLdI
prhWYXiaOlpctOqR63axaKRzXQq8lLS7870BtYEMq0C/HwxknEP8opKsvWmimjuN
Gie7oM8dYNCcOzx+OEI0I9m0HY9HqP7BvbiuykzZL78gci5AuA3I9B3jpI8oqqYq
RikGmIrHpOZPWcxvFosY
=9q0h
-----END PGP SIGNATURE-----

--Sig_/rVQsC.i=_LPMhX4.0hLTXPD--
