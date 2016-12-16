From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [TSN RFC v2 5/9] Add TSN header for the driver
Date: Fri, 16 Dec 2016 23:09:38 +0100
Message-ID: <20161216220938.GB25258@netboy>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
 <1481911153-549-6-git-send-email-henrik@austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Henrik Austad <haustad@cisco.com>,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: henrik@austad.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481911153-549-6-git-send-email-henrik@austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 06:59:09PM +0100, henrik@austad.us wrote:
> +/*
> + * List of current subtype fields in the common header of AVTPDU
> + *
> + * Note: AVTPDU is a remnant of the standards from when it was AVB.
> + *
> + * The list has been updated with the recent values from IEEE 1722, draft 16.
> + */
> +enum avtp_subtype {
> +	TSN_61883_IIDC = 0,	/* IEC 61883/IIDC Format */
> +	TSN_MMA_STREAM,		/* MMA Streams */
> +	TSN_AAF,		/* AVTP Audio Format */
> +	TSN_CVF,		/* Compressed Video Format */
> +	TSN_CRF,		/* Clock Reference Format */
> +	TSN_TSCF,		/* Time-Synchronous Control Format */
> +	TSN_SVF,		/* SDI Video Format */
> +	TSN_RVF,		/* Raw Video Format */
> +	/* 0x08 - 0x6D reserved */
> +	TSN_AEF_CONTINOUS = 0x6e, /* AES Encrypted Format Continous */
> +	TSN_VSF_STREAM,		/* Vendor Specific Format Stream */
> +	/* 0x70 - 0x7e reserved */
> +	TSN_EF_STREAM = 0x7f,	/* Experimental Format Stream */
> +	/* 0x80 - 0x81 reserved */
> +	TSN_NTSCF = 0x82,	/* Non Time-Synchronous Control Format */
> +	/* 0x83 - 0xed reserved */
> +	TSN_ESCF = 0xec,	/* ECC Signed Control Format */
> +	TSN_EECF,		/* ECC Encrypted Control Format */
> +	TSN_AEF_DISCRETE,	/* AES Encrypted Format Discrete */
> +	/* 0xef - 0xf9 reserved */
> +	TSN_ADP = 0xfa,		/* AVDECC Discovery Protocol */
> +	TSN_AECP,		/* AVDECC Enumeration and Control Protocol */
> +	TSN_ACMP,		/* AVDECC Connection Management Protocol */
> +	/* 0xfd reserved */
> +	TSN_MAAP = 0xfe,	/* MAAP Protocol */
> +	TSN_EF_CONTROL,		/* Experimental Format Control */
> +};

The kernel shouldn't be in the business of assembling media packets.

Thanks,
Richard
