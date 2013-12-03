From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/7] bridge: Fix the way finding the old local fdb
 entry in br_fdb_changeaddr
Date: Tue, 3 Dec 2013 08:50:35 -0800
Message-ID: <20131203085035.6a11b1de@nehalam.linuxnetplumber.net>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1385966439-26526-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<20131202180917.1e844dde@nehalam.linuxnetplumber.net>
	<1386075326.4038.66.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:65225 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab3LCQuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:50:40 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so21229711pbc.26
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 08:50:39 -0800 (PST)
In-Reply-To: <1386075326.4038.66.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Dec 2013 21:55:26 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> Another approach I can conceive is:
> - Make fdb entries be able to be differentiated from those user added
>   by introducing a flag in struct net_bridge_fdb_entry. 

Yes, this makes more sense; and it would be useful for administration display commands.
