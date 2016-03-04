From: Joe Perches <joe@perches.com>
Subject: Re: [ethtool PATCH v2 10/12] internal.h: TRUE/FALSE macros
Date: Thu, 03 Mar 2016 20:35:16 -0800
Message-ID: <1457066116.4044.125.camel@perches.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
	 <1457065405-19049-11-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0026.hostedemail.com ([216.40.44.26]:42507 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754648AbcCDEfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:35:19 -0500
In-Reply-To: <1457065405-19049-11-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-03 at 20:23 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
[]
> diff --git a/internal.h b/internal.h
[]
> @@ -42,6 +42,14 @@ typedef int32_t s32;
> =A0#include "ethtool-copy.h"
> =A0#include "net_tstamp-copy.h"
> =A0
> +#ifndef TRUE
> +#=A0=A0define TRUE (!0)
> +#endif
> +
> +#ifndef FALSE
> +#=A0=A0define FALSE (!!0)

#define TRUE 1
and
#define FALSE 0
are obvious and typical.

The ! and !! uses don't add anything other than obscurity.
