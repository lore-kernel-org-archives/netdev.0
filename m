From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Fri, 23 Nov 2012 20:42:23 +0100
Message-ID: <20121123194223.GA30549@electric-eye.fr.zoreil.com>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de> <50AFA599.9040108@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44729 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab2KWUGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 15:06:20 -0500
Content-Disposition: inline
In-Reply-To: <50AFA599.9040108@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker <paul.gortmaker@windriver.com> :
> On 12-11-23 10:58 AM, Keitel, Tino (ALC NetworX GmbH) wrote:
[...]
> > With this commit reverted, it works fine. v3.3 is ok, v3.4 contains the
> > bad commit. The commit doesn't revert in a clean way in 3.7-rc6. I
> > attached diff without the tqi changes.

Pre v3.4.5 stable kernel will miss some bql fixes. Namely:
4f4bdaeb40df95499c1ee7ea3fbca9d76174a59e (upstream 914bec1011a25f65cdc)
1414a53d956340ca8b1b27e05ab94ba63e82ed97 (upstream 25426b794efdc70dde7)

-- 
Ueimor
