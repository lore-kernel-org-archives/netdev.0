From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ipxfrm: wrong nl msg sent on deleteall cmd
Date: Mon, 20 Apr 2015 10:05:07 -0700
Message-ID: <20150420100507.489bc092@urahara>
References: <1429099253-24739-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	gregory.hoggarth@alliedtelesis.co.nz
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35152 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbDTRFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 13:05:03 -0400
Received: by pdbqd1 with SMTP id qd1so213596947pdb.2
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 10:05:02 -0700 (PDT)
In-Reply-To: <1429099253-24739-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2015 14:00:53 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> XFRM netlink family is independent from the route netlink family. It's wrong
> to call rtnl_wilddump_request(), because it will add a 'struct ifinfomsg' into
> the header and the kernel will complain (at least for xfrm state):
> 
> netlink: 24 bytes leftover after parsing attributes in process `ip'.
> 
> Reported-by: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied thanks
