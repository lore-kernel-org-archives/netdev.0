From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 00/21] r8169: pull request for 'r8169-for-jeff-20070629'
 branch
Date: Fri, 29 Jun 2007 16:48:24 -0400
Message-ID: <46857018.1030408@pobox.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60044 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753900AbXF2Us1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:48:27 -0400
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from branch 'r8169-for-jeff-20070629' in repository
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169-for-jeff-20070629
> 
> to get the changes below.
> 
> Following mails on netdev describe each patch.
> 
> Distance from 'netdev-2.6-upstream' (c5322b6b7430c8d5ee059178e029d1fe173d3239)
> ------------------------------------------------------------------------------
> 
> f0b5caae6f80c3f986c75dbf0c295a727d37a8d3
> aa08684e506cbb7c5523047975c9161c00098895
> 6f1bd622aa4f7578fb623c80d659fed5f1bc2a74
> 74e88f25c245439c6028aeefaf8817d0abffed07
> ccb2c222b135b05031002428c7af37fbf104772b
> 0f9ca771566d60a47a0e8cac837bafa006fe25e5
> dc0b8eabad0731ab5838b84b155813218463180a
> 7aae02eee1e97b40a28856f40a8ea5f421db53cf
> 7d015a20ef99893101e9c2d9eeacb95b84563ad8
> cd8a6a538940d79173e5b5fc92c5d439201bb8ab
> 7b0004502e114172cbb7da75b66add1293c3af60
> 6d54a502eb244f05fe562296c069662b30f3e3de
> 3ce528c255d5807935ae538c7dfe9786a3d45a1c
> 7e41a2f1928b461e489e5256e13989a02b6c4409
> 607f00af1c998b2a15948f6616e766cbcc9885ae
> 39c51985b355331ff04c1286a474d8521573462a
> e47e1700739025fb1f3111b92767e99778d838f8
> 6e3077d17f4a3c627f57ce4d347beb453ffa9a9e
> 6641a725feebe385179b993a6801e2b902362930
> 794e2548627e76fa5a4fc25ec6f26a01226b18eb
> e7c39d0961889a4836091da87cb785d33fcc36e0
> 
> Diffstat
> --------
> 
>  drivers/net/r8169.c |  944 ++++++++++++++++++++++++++++-----------------------
>  1 files changed, 528 insertions(+), 416 deletions(-)
> 
> Shortlog
> --------
> 
> David S. Miller (1):
>       r8169: kill eth_copy_and_sum()
> 
> Francois Romieu (17):
>       r8169: de-obfuscate modulo arithmetic
>       r8169: add hooks for per-device hw_start handler
>       r8169: add helpers for per-device hw_start handler
>       r8169: populate the hw_start handler for the 8168
>       r8169: populate the hw_start handler for the 8110
>       r8169: prettify mac_version
>       r8169: merge with version 6.001.00 of Realtek's r8169 driver
>       r8169: merge with version 8.001.00 of Realtek's r8168 driver
>       r8169: confusion between hardware and IP header alignment
>       r8169: small 8101 comment
>       r8169: remove the media option
>       r8169: cleanup
>       r8169: add bit description for the TxPoll register
>       r8169: align the IP header when there is no DMA constraint
>       r8169: display some extra debug information during startup
>       r8169: mac address change support
>       r8169: perform RX config change after mac filtering
> 
> Rolf Eike Beer (1):
>       r8169: add endianess annotations to [RT]xDesc
> 
> Stephen Hemminger (2):
>       r8169: use netdev_alloc_skb
>       r8169: Rx path update

pulled, thanks!


