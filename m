From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/3] ethtool: flie option to register dump
Date: Mon, 23 Oct 2006 13:06:46 -0700
Message-ID: <20061023130646.43860b79@freekitty>
References: <20061018104632.27a37d75@freekitty>
	<20061023105142.13b507a7@dxpl.pdx.osdl.net>
	<20061023105703.5f1e13eb@dxpl.pdx.osdl.net>
	<200610241150.19609.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5065 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422800AbWJYQW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 12:22:56 -0400
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200610241150.19609.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Oct 2006 11:50:19 +0200
Ingo Oeser <netdev@axxeo.de> wrote:

> Hi Stephen,
> 
> Stephen Hemminger schrieb:
> > Add ability to take old raw dumps from a file and decode them.
> > It is kind of limited because you still need to have same device
> > as the raw file, but useful for maintainers to decode raw dumps.
> 
> What about putting the (Permanent) MAC into the first 4-6 octets 
> of the hexdump and decode+check+warn using this info first 
> to avoid mixing up files?
> 
> Maybe only the first 4 octets to enhance privacy and still being able
> to detect known "bad" series.
> 
> This might prevent user errors when sending such files
> to developers.
> 
> Regards
> 
> Ingo Oeser


The existing output format for raw is fine for piping into utilities
like hexdump

-- 
Stephen Hemminger <shemminger@osdl.org>
