From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net 3/3] net: cdc_ncm: fix error path for single interface probing
Date: Tue, 22 Jan 2013 09:58:05 +0100
Message-ID: <2830395.rGXyQGCbQc@linux-5eaq.site>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no> <1358783440-11459-4-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37743 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845Ab3AVI6C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 03:58:02 -0500
In-Reply-To: <1358783440-11459-4-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 January 2013 16:50:40 Bj=F8rn Mork wrote:
> commit bbc8d92 (net: cdc_ncm: add Huawei devices) implemented
> support for devices with a single combined control and data
> interface. Fix up the error path so that we do not double
> release such interfaces in case of probing failures.

Hi Bj=F8rn,

this should go also into stable. Could you submit?

	Regards
		Oliver
