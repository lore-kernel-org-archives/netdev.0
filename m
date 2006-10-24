From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 2/3] ethtool: flie option to register dump
Date: Tue, 24 Oct 2006 11:50:19 +0200
Message-ID: <200610241150.19609.netdev@axxeo.de>
References: <20061018104632.27a37d75@freekitty> <20061023105142.13b507a7@dxpl.pdx.osdl.net> <20061023105703.5f1e13eb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:28387 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1030262AbWJXJul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 05:50:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061023105703.5f1e13eb@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger schrieb:
> Add ability to take old raw dumps from a file and decode them.
> It is kind of limited because you still need to have same device
> as the raw file, but useful for maintainers to decode raw dumps.

What about putting the (Permanent) MAC into the first 4-6 octets 
of the hexdump and decode+check+warn using this info first 
to avoid mixing up files?

Maybe only the first 4 octets to enhance privacy and still being able
to detect known "bad" series.

This might prevent user errors when sending such files
to developers.

Regards

Ingo Oeser
