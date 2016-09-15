From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC 09/11] Add LL2 RoCE interface
Date: Thu, 15 Sep 2016 13:20:13 +0300
Message-ID: <20160915102013.GZ26069@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-10-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qrotSzihSRAsrOtf"
Cc: dledford@redhat.com, davem@davemloft.net, Yuval.Mintz@qlogic.com,
        Ariel.Elior@qlogic.com, Michal.Kalderon@qlogic.com,
        rajesh.borundia@qlogic.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Ram Amrani <Ram.Amrani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46106 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765375AbcIOKUU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 06:20:20 -0400
Content-Disposition: inline
In-Reply-To: <1473696465-27986-10-git-send-email-Ram.Amrani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qrotSzihSRAsrOtf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 12, 2016 at 07:07:43PM +0300, Ram Amrani wrote:
> Add light L2 interface for RoCE.
>
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Ram Amrani <Ram.Amrani@qlogic.com>
> ---

<....>

> +		DP_ERR(cdev,
> +		       "QED RoCE set MAC filter failed - roce_info/ll2 NULL\n");
> +		return -EINVAL;
> +	}
> +
> +	p_ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
> +	if (!p_ptt) {
> +		DP_ERR(cdev,
> +		       "qed roce ll2 mac filter set: failed to acquire PTT\n");
> +		return -EINVAL;
> +	}

Please use single style for your debug prints QED RoCE vs. qed roce.

--qrotSzihSRAsrOtf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2nXdAAoJEORje4g2clinOU8QAJLhUZ8nYTEQEFOOD7OMpo5m
nIfxpEexVe3rSegE5Z6qHEya6WNKsA53tSlamweaIDgKkZmDHqcSo2hgL+NPbLIu
Z0xbuQ4oIGuEfBtQxCLHrts+oD8RYxJTsmS7WzV8GqoaVYwCgoXlZxiJPnm8ahBf
qfHtfJeVk7ylTFx6eMAG+w9flB8rSmPUCGntu/qDNO1FdXREmcToxR+WNA5RBAfJ
9SfW1XkjTiiXKuKAlnMz7/FQVayhyPrFkhJhiSM4RiOmdK3I2Gd8KnidfQf1Dob2
GXPzuq1PhP4YvR9MZFJ3ufcbSsKSnTc+47fyq58wswWbIieuzvoL/o6pIAzFyEKx
8aghIRMMVhgnvhcSYMsX3Cy4oxlnqNLUhBgt4PgFKWDohEGEKEB6bHb5FStFJ9g0
olLZB8SI7RlwJEFinkJzGvbFIT4MDkSBuVKbV4POZC9jQKZOmShTrAHWIrjoluFl
IWlDAgaWr3WMeXRfnCaNaigHyIwoAiYqeUpM0RyziwDxXrm5B9sToXrEv+E4bgd7
KetvfWJ5favREqNjRIOYUETon8ZbMwfLbYe81uMNAEZDjARBHeFw5fY8wr79Y8Hq
NBYN1cJhEooNG1asTm37Y7pKjGZHONs/Pm3A0CcRbxp1mQR4lRUYrCCfv/+ppsvK
boHU/fMY5sZrbw3bqiBF
=Hzyi
-----END PGP SIGNATURE-----

--qrotSzihSRAsrOtf--
