From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 2/4] NFC: nxp-nci: Add support for NXP NCI chips
Date: Fri, 30 Jan 2015 01:10:48 +0100
Message-ID: <20150130001048.GD20998@ribalta.ger.corp.intel.com>
References: <1421940460-14049-1-git-send-email-clement.perrochaud@effinnov.com>
 <1421940460-14049-3-git-send-email-clement.perrochaud@effinnov.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	=?iso-8859-1?Q?Cl=E9ment?= Perrochaud
	<clement.perrochaud-3arQi8VN3Tc@public.gmane.org>, sunil.jogi-3arQi8VN3Tc@public.gmane.org,
	jerome.pele-3arQi8VN3Tc@public.gmane.org, Charles.Gorand-Effinnov-3arQi8VN3Tc@public.gmane.org,
	lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, lefrique-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cuissard-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, hirent-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1421940460-14049-3-git-send-email-clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Clement,

On Thu, Jan 22, 2015 at 04:27:38PM +0100, clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org wrote:
> @@ -686,7 +686,7 @@ L:	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org (moderated for non-subscribers)
>  W:	http://blackfin.uclinux.org/
>  S:	Supported
>  F:	sound/soc/blackfin/*
> - 
> +
Unneeded change, please remove it.

> +config NFC_NXP_NCI
> +	tristate "NXP-NCI NFC driver"
> +	depends on NFC_NCI
> +	default n
> +	---help---
> +	  Generic core driver for NXP NCI chips.
It usually is nice to be more specific and describe which chipsets
(e.g. NPC100) this driver supports among all the NXP NCI chipsets.

> +struct nxp_nci_phy_ops {
> +	int (*enable)(void *id);
> +	int (*fw_enable)(void *id);
Wouldn't a int (*enable)(void *id, enum nxp_nci_mode mode); hook be
enough ?

Cheers,
Samuel.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
