From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 3/3] rhashtable: allow to unload test module
Date: Fri, 20 Feb 2015 12:01:52 +0000
Message-ID: <20150220120152.GD4586@casper.infradead.org>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <c0c78ef9a196812dc8a2922bb2a957a04c6dbfb6.1424389682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johunt@akamai.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51397 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbbBTMBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 07:01:53 -0500
Content-Disposition: inline
In-Reply-To: <c0c78ef9a196812dc8a2922bb2a957a04c6dbfb6.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 12:53am, Daniel Borkmann wrote:
> There's no good reason why to disallow unloading of the rhashtable
> test case module.
> 
> Commit 9d6dbe1bbaf8 moved the code from a boot test into a stand-alone
> module, but only converted the subsys_initcall() handler into a
> module_init() function without a related exit handler, and thus
> preventing the test module from unloading.
> 
> Fixes: 9d6dbe1bbaf8 ("rhashtable: Make selftest modular")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Thomas Graf <tgraf@suug.ch>
