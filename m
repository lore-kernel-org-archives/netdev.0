From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 14:02:20 +0100
Message-ID: <20070109130220.GA4060@ff.dom.local>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com> <20070109092602.GC1703@ff.dom.local> <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:58487 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751384AbXAINA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 08:00:28 -0500
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 11:27:59AM +0100, Thibaut VARENE wrote:
...
> I suspected both and changed both the disk and the ram for quality
> parts, that I tested afterwards. Both passed thorough tests.
> 
> Finally, using the other NIC on the box (a VIA Rhine II, 100Mbps),
> works absolutely fine.

If you are not tired, I'd suggest two more tests:

- as above but with NIC set to 100Mbps also,

- long downloading but without nfs e.g. ftp
(btw. there were some patches after 2.6.19
for rpc memory races).

Jarek P.

PS: Maintainers were cc-ed, I hope?
