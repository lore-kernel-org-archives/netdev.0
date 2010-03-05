From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Fri, 5 Mar 2010 20:21:53 +0900
Message-ID: <20100305202153.fb39cd64.ken_kawasaki@spring.nifty.jp>
References: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
	<1267747341.2819.177.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:58352 "EHLO
	defg302p.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755021Ab0CEL1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 06:27:41 -0500
Received: from userg507.nifty.com (userg507p.nifty.com [172.22.128.87])by defg302p.nifty.com with ESMTP id o25BN7LW000652
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 20:23:07 +0900
In-Reply-To: <1267747341.2819.177.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> The CIS files under firmware/ are, according to firmware/WHENCE,
> 'developed by the pcmcia-cs project'.  So I had a look at what's left of
> the pcmcia-cs project and its last release, and found that it includes:
> 
> - the tool 'pack_cis' which compiles a text version of CIS to the
>   standard binary format
> - text versions of most of the CIS files
> 
> Since the text versions contain comments which are excluded from the
> binary format, I believe they should be considered the 'preferred form
> for modification' and included in the linux-2.6 and linux-firmware trees
> along with the binaries.
> 

Actually, it is better to build CIS by "pack_cis /lib/firmware/cis/src/xxx.cis"
instead of "IHEX /lib/firmware/cis/xxx.cis".

In that case, the "pack_cis" tool should be included in the kernel-tree.

Ken.

