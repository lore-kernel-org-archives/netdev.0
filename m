From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_tables: Release memory obtained by
 kasprintf
Date: Tue, 3 Oct 2017 15:21:53 +0200
Message-ID: <20171003132153.GA2379@salvia>
References: <385554261c080cd3fc4adc093e68366a6d3dff77.1505889128.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.95.27.120] ([213.95.27.120]:39717 "EHLO
        ganesha.gnumonks.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdJCNXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 09:23:14 -0400
Content-Disposition: inline
In-Reply-To: <385554261c080cd3fc4adc093e68366a6d3dff77.1505889128.git.arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 12:31:28PM +0530, Arvind Yadav wrote:
> Free memory region, if nf_tables_set_alloc_name is not successful.

Applied, thanks.

I have added this tag to this patch:

Fixes: 387454901bd6 ("netfilter: nf_tables: Allow set names of up to 255 chars")
