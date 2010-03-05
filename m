From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re:[PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Fri, 5 Mar 2010 21:01:51 +0900
Message-ID: <20100305210151.b27ce31a.ken_kawasaki@spring.nifty.jp>
References: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
	<1267747341.2819.177.camel@localhost>
	<20100305202153.fb39cd64.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg506.nifty.com ([202.248.238.86]:17145 "EHLO
	userg506.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab0CEMCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 07:02:16 -0500
In-Reply-To: <20100305202153.fb39cd64.ken_kawasaki@spring.nifty.jp>
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
 
Actually, it is better to build CIS by "pack_cis firmware/cis/src/xxx.cis"
instead of "IHEX firmware/cis/xxx.cis".
 
In that case, the "pack_cis" tool should be included in the kernel-tree.
 
Ken.
