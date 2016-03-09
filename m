From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH iproute2 v2 1/1] tc: introduce IFE action
Date: Wed, 9 Mar 2016 14:12:14 +0100
Message-ID: <20160309131214.GB27306@orbyte.nwl.cc>
References: <1457525076-6923-1-git-send-email-jhs@emojatatu.com>
 <1457525076-6923-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemming@brocade.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37984 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbcCINMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 08:12:17 -0500
Content-Disposition: inline
In-Reply-To: <1457525076-6923-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 07:04:36AM -0500, Jamal Hadi Salim wrote:
> +static void ife_explain(void)
> +{
> +	fprintf(stderr,
> +		"Usage:... ife {decode|encode} {ALLOW|USE} [dst DMAC] [src SMAC] [type TYPE] [CONTROL] [index INDEX]\n");

I'm just nitpicking here, but this syntax implies that ALLOW and USE are
mandatory and mutually exclusive. Looking at the code they're neither
(although specifying both might not make sense). OTOH you could probably
'use mark' and 'allow prio'. So I'd suggest '[ALLOW] [USE]' instead.

> +	fprintf(stderr,
> +		"\tALLOW := Encode direction. Allows encoding specified metadata\n"
> +		"\t\t e.g \"allow mark\"\n"
> +		"\tUSE := Encode direction. Enforce Static encoding of specified metadata\n"
> +		"\t\t e.g \"use mark 0x12\"\n"

I'm missing a list of what actual keywords can be given, but after all
this is just a help text and a man page will provide much more detail
anyway (which you are about to submit too, are you? :).

Apart from that:

Acked-by: Phil Sutter <phil@nwl.cc>
