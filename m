From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/7] NFC: nfcmrvl: do not use device-managed resources
Date: Wed, 29 Mar 2017 22:44:40 +0200
Message-ID: <20170329204440.GF15708@localhost>
References: <20170329162112.18121-1-johan@kernel.org>
 <20170329162112.18121-4-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Vincent Cuissard <cuissard-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170329162112.18121-4-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 06:21:08PM +0200, Johan Hovold wrote:
> This specifically fixes a NULL-pointer dereference when using the n_nci
> line discipline on one end of a Unix98 pty as well as resource leaks in
> the registration error paths.

I noticed I forgot to actually fix up the error paths, so will send a v2
tomorrow.

Johan
