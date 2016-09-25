From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 02/16] IB/pvrdma: Add user-level shared functions
Date: Sun, 25 Sep 2016 15:29:36 +0300
Message-ID: <20160925122936.GC4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <b52db7f59d69089f7b1d53311574143c4da8252a.1474759181.git.aditr@vmware.com>
 <20160925072624.GV4088@leon.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="tzjrJU3+iJ6c5SNx"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160925072624.GV4088@leon.nu>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tzjrJU3+iJ6c5SNx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 25, 2016 at 10:26:24AM +0300, Leon Romanovsky wrote:

<...>

> > +
> > +/* PVRDMA send queue work request */
> > +struct pvrdma_sq_wqe_hdr {
> > +	__u64 wr_id;		/* wr id */
> > +	__u32 num_sge;		/* size of s/g array */
> > +	__u32 total_len;	/* reserved */
> > +	__u32 opcode;		/* operation type */
> > +	__u32 send_flags;	/* wr flags */
> > +	union {
> > +		__u32 imm_data;
> > +		__u32 invalidate_rkey;
> > +	} ex;
> > +	__u32 reserved;
> > +	union {
> > +		struct {
> > +			__u64 remote_addr;
> > +			__u32 rkey;
> > +			__u8 reserved[4];
> > +		} rdma;
> > +		struct {
> > +			__u64 remote_addr;
> > +			__u64 compare_add;
> > +			__u64 swap;
> > +			__u32 rkey;
> > +			__u32 reserved;
> > +		} atomic;
> > +		struct {
> > +			__u64 remote_addr;
> > +			__u32 log_arg_sz;
> > +			__u32 rkey;
> > +			union {
> > +				struct pvrdma_exp_cmp_swap  cmp_swap;
> > +				struct pvrdma_exp_fetch_add fetch_add;
> > +			} wr_data;
> > +		} masked_atomics;
> > +		struct {
> > +			__u64 iova_start;
> > +			__u64 pl_pdir_dma;
> > +			__u32 page_shift;
> > +			__u32 page_list_len;
> > +			__u32 length;
> > +			__u32 access_flags;
> > +			__u32 rkey;
> > +		} fast_reg;
> > +		struct {
> > +			__u32 remote_qpn;
> > +			__u32 remote_qkey;
> > +			struct pvrdma_av av;
> > +		} ud;
> > +	} wr;
> > +};
>
> No, I have half-baked patch series which refactors this structure in kernel.

Sorry, this patch series is not needed in kernel.

> There is no need to put this structure in UAPI.

This is still relevant.

Thanks

--tzjrJU3+iJ6c5SNx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX58MwAAoJEORje4g2clinbaEP/RExt9Kvb4GHs6B9R/0/5qEY
/+kXf1ciwmCYanyRmpwjM3lsBaPIo3XIDtHi+O6371MmLwiH0UYW9nCvAXJt51D3
Oce7JvGafQQmwqsv4nAhH3kTKYE/C/lmtIHN6sdAf6lAUZnxoDyFyoFLx3k3sf1K
wLUzLTVSP9Hy0PRQEFw1z8p3ii9nlb7lQV/zqfBM7C6PsrTGrF/Y4GIu1jlCrwEe
s32HIrLsR5yUEPDiEJ1A2SRwwsuM9lwcXV2Nk3xQjyv9WJetnTPKUFVCtIRv8Aol
qjZ3Le8hD0XqndFQcTIIhzlimWcRtjNAdaQC5pkf05q9OOcD/Tp8VugQoRj/r1K5
wl2brfrqbsJN43FdF+sopWIwSlNmtSoMVIFDDPKuhEw9uYt/3R3jibzxgR6E7hXF
+ZH13K69MlXB1tpe8PW7ZSDacn3UZN+XPVzZLEnu17MqViTmDq/5v4Of8K9dQLGn
yz/SiCe25d86sK+2p1OIJBqFGFx1F9qNYZtQNn3aw3V0Gy/o/9u2Oj5Cgm8QLLms
bH391hgjC/MYAYS/X8fYLVMjxKK8Exr6ng8SN4yL3EGkZFq7j9IRqhAd0eklcIfk
H8pDoXKHSd/5gCh4ILnZ0RpvX/r48YZEytMgpLIA2+OIzRr3A9tYAleCaJNafisd
cKgMjmwmmJFjp0tP6CHP
=KqTV
-----END PGP SIGNATURE-----

--tzjrJU3+iJ6c5SNx--
