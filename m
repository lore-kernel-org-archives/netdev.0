From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_nat_tftp broken in 4.8?
Date: Wed, 9 Nov 2016 22:56:14 +0100
Message-ID: <20161109215614.GA21923@breakpoint.cc>
References: <b3fb3d07-fb0b-e4a5-20fe-bdc2abc8f6fc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        fgao@ikuai8.com, pablo@netfilter.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48698 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751498AbcKIV6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 16:58:22 -0500
Content-Disposition: inline
In-Reply-To: <b3fb3d07-fb0b-e4a5-20fe-bdc2abc8f6fc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> wrote:
> After updating my workstation from 4.4 to 4.8, which also serves as a
> NAT gateway for local machines, I noticed that TFTP across this NAT box
> broke:

does 'sysctl net.netfilter.nf_conntrack_helper=1' help?
