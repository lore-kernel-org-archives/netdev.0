From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
Date: Sat, 10 Nov 2007 21:56:42 +0100
Message-ID: <p73y7d5zunp.fsf@bingen.suse.de>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:35043 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754058AbXKJU4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 15:56:43 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com> (Fred L. Templin's message of "Tue\, 6 Nov 2007 17\:16\:11 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Templin, Fred L" <Fred.L.Templin@boeing.com> writes:
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +	/* ISATAP (RFC4214) - router address in daddr */
> +	if (!strncmp(parms->name, "isatap", 6)) {

Modern distributions tend to have daemons to automatically rename
network interfaces using SIOCSIFNAME. Not sure they would touch
isatap*, but they or someone else might. I would be likely safer to
not base your user interface on the name only, but use a flag
or number somewhere else.

-Andi

