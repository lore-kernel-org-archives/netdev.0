From: Bastian Blank <waldi@debian.org>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 23:29:15 +0100
Message-ID: <20090323222915.GA29609@wavehammer.waldi.eu.org>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk> <1237503884.16140.23.camel@HP1> <20090319232541.GA19262@wavehammer.waldi.eu.org> <20090320.155030.164080684.davem@davemloft.net> <1237844879.18617.20.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wavehammer.waldi.eu.org ([82.139.201.20]:41873 "EHLO
	wavehammer.waldi.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbZCWW3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:29:18 -0400
Content-Disposition: inline
In-Reply-To: <1237844879.18617.20.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2009 at 02:47:59PM -0700, Michael Chan wrote:
> I'd also like to add the version information to the bnx2_fw_file_entry
> struct instead of embedding it in the file name.  It is more flexible
> this way as each section can have different versions and can be updated
> separately.  So it will look something like:
> 
> struct bnx2_fw_file_entry {
> 	__be32 start_addr;
> 	__be32 version;
> 	struct bnx2_fw_file_section text;
> 	struct bnx2_fw_file_section data;
> 	struct bnx2_fw_file_section sbss;
> 	struct bnx2_fw_file_section bss;
> 	struct bnx2_fw_file_section rodata;
> };

And how do you want to handle the compatibility? One firmware file have
to work with many kernels, which was always described as impossible.

Bastian

-- 
Women are more easily and more deeply terrified ... generating more
sheer horror than the male of the species.
		-- Spock, "Wolf in the Fold", stardate 3615.4
