From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v3 2/2] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 27 Oct 2015 12:40:42 +0000
Message-ID: <yw1x8u6oeb79.fsf@unicorn.mansr.com>
References: <1445895295-16778-1-git-send-email-mans@mansr.com>
	<1445895295-16778-2-git-send-email-mans@mansr.com>
	<20151027150209.043946d4@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:53731 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932213AbbJ0Mku convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 08:40:50 -0400
In-Reply-To: <20151027150209.043946d4@samsung9> (Stephen Hemminger's message
	of "Tue, 27 Oct 2015 15:02:09 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

>> +	.get_settings		=3D nb8800_get_settings,
>> +	.set_settings		=3D nb8800_set_settings,
>> +	.nway_reset		=3D nb8800_nway_reset,
>> +	.get_link		=3D ethtool_op_get_link,
>> +};
>> +
>
> Since you are implementing ethtool please add a driver
> info function.

I don't know what I'd set there that the fallback code doesn't.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
