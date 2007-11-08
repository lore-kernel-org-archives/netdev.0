From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 01/05] ipv6: RFC4214 Support (2)
Date: Wed, 7 Nov 2007 17:14:13 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC05@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE2@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC04@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:41112 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbXKHBOP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 20:14:15 -0500
Received: from stl-av-01.boeing.com (stl-av-01.boeing.com [192.76.190.6])
	by slb-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id lA81EE6d010949
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 17:14:15 -0800 (PST)
Received: from stl-av-01.boeing.com (localhost [127.0.0.1])
	by stl-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id lA81EED0008792
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 19:14:14 -0600 (CST)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by stl-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id lA81EE97008781
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 19:14:14 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC04@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I apologize for this, but it appears that my mailer is still
inserting line breaks where it shouldn't; please disregard.

Can anyone advise on how to configure Microsoft Office so
that the line breaks do not occur?

Thanks - Fred
fred.l.templin@boeing.com

> -----Original Message-----
> From: Templin, Fred L
> Sent: Wednesday, November 07, 2007 5:09 PM
> To: netdev@vger.kernel.org
> Subject: [PATCH 01/05] ipv6: RFC4214 Support (2)
> 
> 
> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This is experimental support for the Intra-Site Automatic
> Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
> the SIT module, and is configured using the unmodified
> "ip" utility with device names beginning with: "isatap".
> 
> The following diffs are specific to the Linux 2.6.23
> kernel distribution.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> 
> ---
> 
> --- linux-2.6.23/include/linux/if.h.orig	2007-10-29
> 09:22:26.000000000 -0700
> +++ linux-2.6.23/include/linux/if.h	2007-11-07 13:48:08.000000000
> -0800
> @@ -61,6 +61,7 @@
>  #define IFF_MASTER_ALB	0x10		/* bonding master,
balance-alb.
> */
>  #define IFF_BONDING	0x20		/* bonding master or slave
> */
>  #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for
validation
> */
> +#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)
> */
> 
>  #define IF_GET_IFACE	0x0001		/* for querying only */
>  #define IF_GET_PROTO	0x0002
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
