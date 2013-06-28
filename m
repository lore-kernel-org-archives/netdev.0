From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] net: cdc_ether: allow combined control and data interface
Date: Fri, 28 Jun 2013 17:32:25 +0200
Message-ID: <1419214.UqpcbE98T1@linux-5eaq.site>
References: <1372432629-17245-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:33493 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3F1Pa5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 11:30:57 -0400
In-Reply-To: <1372432629-17245-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 28 June 2013 17:17:08 Bj=F8rn Mork wrote:
> Some Icera based Huawei modems handled by this driver are not
> completely CDC ECM compliant, using the same USB interface for both
> control and data. The CDC functional descriptors include a Union
> naming this interface as both master and slave, so it is supportable
> by relaxing the descriptor parsing in case these interfaces are
> identical.

The disconnect handler is uselessly complex. Just return if the
interfaces are identical. There's nothing to do in that case.

	Regards
		Oliver
