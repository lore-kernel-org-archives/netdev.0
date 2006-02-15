From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 5/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Wed, 15 Feb 2006 20:35:37 -0200
Message-ID: <39e6f6c70602151435r5b965670oab580c75bbaee7ab@mail.gmail.com>
References: <1140042162.8745.30.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Andre Hendry <ahendry@tusc.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932183AbWBOWfj@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1140042162.8745.30.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/15/06, Shaun Pereira <spereira@tusc.com.au> wrote:

> +               switch (*p) {
> +                       case X25_FAC_CALLING_AE:
> +                               if (p[1] > 33)
> +                               break;
> +                               dte_facs->calling_len = p[2];
> +                               memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
> +                               *vc_fac_mask |= X25_MASK_CALLING_AE;
> +                               break;

Can this '33' magic number be replaced with a define or sizeof(something)?

- Arnaldo
