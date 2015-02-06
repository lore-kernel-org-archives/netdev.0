From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Fri, 6 Feb 2015 10:40:03 +0000
Message-ID: <20150206104003.GA18978@casper.infradead.org>
References: <cover.1423097592.git.tgraf@suug.ch>
 <54D2D656.8060709@windriver.com>
 <20150205084737.GA15549@casper.infradead.org>
 <54D3346E.4040302@windriver.com>
 <20150205101954.GA24388@casper.infradead.org>
 <54D42892.3030808@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33115 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbbBFKkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 05:40:07 -0500
Content-Disposition: inline
In-Reply-To: <54D42892.3030808@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 at 10:36am, Ying Xue wrote:
> After I applied the below change on the latest net-next tree with the series
> patches, panic happens during kernel boot stage as follows:

Sorry about that. I must have booted the wrong kernel. On the positive
side, I was able to reproduce the original race today. The key was to
use 8 instead of 4 CPUs in the VM. I'm testing with the fixed build
right now.
