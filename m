From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux 2.6.25-rc6: WARNING: at net/ipv4/tcp_input.c:2510
Date: Thu, 3 Apr 2008 13:17:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804031315360.21524@wrl-59.cs.helsinki.fi>
References: <47EBCB75.6030600@unixsol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Georgi Chorbadzhiyski <gf@unixsol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43457 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbYDCKRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 06:17:50 -0400
In-Reply-To: <47EBCB75.6030600@unixsol.org>
Content-ID: <Pine.LNX.4.64.0804031315362.21524@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Mar 2008, Georgi Chorbadzhiyski wrote:

> A week ago I updated one of my servers to 2.6.25-rc6 and today looking
> through logs I've found these:
> 
> [380219.823434] ------------[ cut here ]------------
> [380219.823450] WARNING: at net/ipv4/tcp_input.c:2510 tcp_ack+0xc7e/0x177d()

Hi,

Is this reproducable for you? If yes, is it possible for you to run 
processing expensive verification of TCP state (validates TCP write queue 
invariants multiple times per ACK by scanning through the write queue) on 
such machine?

-- 
 i.
