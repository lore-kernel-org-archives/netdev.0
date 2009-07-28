From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific members
Date: Tue, 28 Jul 2009 09:57:15 +0300
Message-ID: <200907280957.15889.remi.denis-courmont@nokia.com>
References: <4A6DC314.2010303@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:26839 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbZG1GzB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 02:55:01 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6S6sngm032328
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 09:54:50 +0300
Received: from leon.remlab.net (esdhcp03562.research.nokia.com [172.21.35.62])
	by mgw-da01.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6S6sf7J005127
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 09:54:41 +0300
In-Reply-To: <4A6DC314.2010303@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 27 July 2009 18:09:08 ext Lucian Adrian Grijincu wrote:
> +#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
>  	void			*ax25_ptr;	/* AX.25 specific data */
> +#endif
> +#ifdef CONFIG_WIRELESS
>  	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
>  						   assign before registering */
> +#endif

If I'm not mistaken, AX.25 can only be used with ARPHRD_AX25 devices, n=
o?=20
Should there be a single opaque pointer for all non-generic address fam=
ilies=20
do, that would only be used by the one matching the header type?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

