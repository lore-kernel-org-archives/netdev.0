From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH usb-next 2/2] net: qmi_wwan: add support for ZTE MF820D
Date: Fri, 16 Mar 2012 08:10:48 -0700
Message-ID: <20120316151048.GA28696@kroah.com>
References: <1331908887-14068-1-git-send-email-bjorn@mork.no>
 <1331908887-14068-3-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:32811 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032852Ab2CPPKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 11:10:52 -0400
Received: by yhmm54 with SMTP id m54so4334367yhm.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 08:10:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1331908887-14068-3-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 03:41:27PM +0100, Bj=F8rn Mork wrote:
> ZTE have yet to discover the magic of USB descriptors.  These
> devices use ff/ff/ff for class/subclass/protocol regardless of
> function, except for usb-storage.  Use an interface number
> whitelist to force the driver to bind only to the QMI/wwan
> interface.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
> Hello Greg and David,
>=20
> is it possible to get this into the queue for 3.4 via usb-next as
> well? It was supposed to be a simple pid/vid addition, but the
> ZTE descriptor stupidity requires us to match on USB interface
> numbers.

This requires patch 1/2, right?  If so, I'll be glad to take this in my
tree if David doesn't mind.

thanks,

greg k-h
