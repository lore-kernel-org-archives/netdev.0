From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Outreachy kernel] Re: [PATCH] net: netfilter: Remove multiple
 assignment.
Date: Mon, 27 Mar 2017 14:21:53 +0200
Message-ID: <20170327122153.GA25113@salvia>
References: <20170325124946.GA9109@arushi-HP-Pavilion-Notebook>
 <20170327120827.GA15676@salvia>
 <CA+XqjF_4cXL58vnxgKmawuZ4F0ZqvU1KvAtRbJv_r1ArLTpExw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58496 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753186AbdC0MW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 08:22:27 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E6380EAA77
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 14:21:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D825DBAC2D
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 14:21:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3E5F3C8833
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 14:21:53 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CA+XqjF_4cXL58vnxgKmawuZ4F0ZqvU1KvAtRbJv_r1ArLTpExw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 05:48:41PM +0530, Arushi Singhal wrote:
> On Mon, Mar 27, 2017 at 5:38 PM, Pablo Neira Ayuso <pablo@netfilter.org>
> wrote:
> 
> > On Sat, Mar 25, 2017 at 06:19:47PM +0530, Arushi Singhal wrote:
> > > This patch removes multiple assignments.
> > > Done using coccinelle.
> > > @@
> > > identifier i1,i2;
> > > constant c;
> > > @@
> > > - i1=i2=c;
> > > + i1=c;
> > > + i2=c;
> >
> > You have to explain why this is bad.
> >
> 
> It is against the kernel coding style and we have to avoid multiple
> assignments to make the code more readable.
> This error is found using Checkpatch.pl script.

Then, please place this information in your patch description.

Thanks!
