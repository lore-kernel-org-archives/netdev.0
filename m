From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Fri, 20 Feb 2009 10:09:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902201006110.31742@wrl-59.cs.helsinki.fi>
References: <200902192304.35547.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60407 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbZBTIJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:09:54 -0500
In-Reply-To: <200902192304.35547.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Feb 2009, Denys Fedoryschenko wrote:

> If it is interesting for anybody, on loaded proxy server, at beginning:
> 
> [   21.587816] netconsole: remote ethernet address 00:04:23:af:02:ca
> [   21.591028] console [netcon0] enabled
> [   21.591486] netconsole: network logging started
> [   23.942232] sd 11:0:0:0: [sda] 1146040320 512-byte hardware sectors: (586 
> GB/546 GiB)
> [   23.943077] sd 11:0:0:0: [sda] Write Protect is off
> [   23.943138] sd 11:0:0:0: [sda] Mode Sense: 06 00 10 00
> [   23.943182] sd 11:0:0:0: [sda] Write cache: enabled, read cache: enabled, 
> supports DPO and FUA
> [  239.315726] Leak r=1 3

This is a local tcp sender counting retrans_out incorrectly. I'll try to 
go through the recent changes as soon as I get some free time.


-- 
 i.
