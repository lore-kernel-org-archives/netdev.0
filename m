From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 1/7] bridge: Fix the way finding the old local fdb
 entry in br_fdb_changeaddr
Date: Wed, 04 Dec 2013 16:55:57 +0900
Message-ID: <1386143757.3704.1.camel@ubuntu-vm-makita>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1385966439-26526-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <20131202180917.1e844dde@nehalam.linuxnetplumber.net>
	 <1386075326.4038.66.camel@ubuntu-vm-makita>
	 <20131203085035.6a11b1de@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:52968 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab3LDH4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 02:56:07 -0500
In-Reply-To: <20131203085035.6a11b1de@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 08:50 -0800, Stephen Hemminger wrote:
> On Tue, 03 Dec 2013 21:55:26 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
> > Another approach I can conceive is:
> > - Make fdb entries be able to be differentiated from those user added
> >   by introducing a flag in struct net_bridge_fdb_entry. 
> 
> Yes, this makes more sense; and it would be useful for administration display commands.

Thanks, I will change and resend this.

Toshiaki Makita
