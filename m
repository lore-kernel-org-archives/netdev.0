From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 02/21] RDS: Main header file
Date: Tue, 27 Jan 2009 09:34:16 +0200
Message-ID: <200901270934.16669.remi.denis-courmont@nokia.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-3-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: "ext Andy Grover" <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:42185 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbZA0HfO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 02:35:14 -0500
In-Reply-To: <1233022678-9259-3-git-send-email-andy.grover@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 January 2009 04:17:39 ext Andy Grover, you wrote:
> +/*
> + * XXX randomly chosen, but at least seems to be unused:
> + * #               18464-18768 Unassigned
> + * We should do better.  We want a reserved port to discourage unpri=
v'ed
> + * userspace from listening.
> + */
> +#define RDS_PORT	18634

Internet transport protocol port number? IANA has a process for assigni=
ng port=20
numbers to proprietary protocols.

Not that I'd blame you, as I inherited VLC media player's wide abuse of=
 port=20
1234 as its current network core maintainer :(

> +#ifndef AF_RDS
> +#define AF_RDS          28      /* Reliable Datagram Socket     */
> +#endif
> +
> +#ifndef PF_RDS
> +#define PF_RDS          AF_RDS
> +#endif

You should probably remove that and put the last patch of your series a=
head of=20
this one.

> +#ifndef SOL_RDS
> +#define SOL_RDS         272
> +#endif

This is used by RXRPC nowadays, although I myself don't really understa=
nd why=20
socket option levels need to be unique across all families.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

