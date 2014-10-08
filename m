From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware: does the patch below against current kernel make a difference?
Date: Thu, 9 Oct 2014 00:17:26 +0200
Message-ID: <20141008221726.GA25515@electric-eye.fr.zoreil.com>
References: <542B3829.3010108@crashplan.pro>
 <20141005165920.GA21926@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw>
 <20141006221307.GB10936@electric-eye.fr.zoreil.com>
 <54359E9C.7060704@crashplan.pro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ceriel Jacobs <linux-ide@crashplan.pro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52231 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbaJHWRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 18:17:36 -0400
Content-Disposition: inline
In-Reply-To: <54359E9C.7060704@crashplan.pro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ceriel Jacobs <linux-ide@crashplan.pro> :
[...]
> Francois, could you help me apply your patch?

$ git describe
v3.13
$ patch -p1 --dry-run < /tmp/plop
checking file drivers/net/ethernet/realtek/r8169.c
Hunk #1 succeeded at 467 (offset -1 lines).
Hunk #2 succeeded at 5275 (offset -5 lines).

$ git rev-list v3.16 -- drivers/net/ethernet/realtek/r8169.c | while read x; do echo $x:$(git cat-file -p $x:drivers/net/ethernet/realtek/r8169.c | md5sum); done | grep 95056b56932b375f8b65a6379009f704

-> oualou

Where does your 3.13 source tree come from ?

-- 
Ueimor
