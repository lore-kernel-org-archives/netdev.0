From: Jiri Benc <jbenc@redhat.com>
Subject: Re: vxlan: use after free error
Date: Tue, 30 May 2017 13:54:20 +0200
Message-ID: <20170530135420.51ff8617@griffin>
References: <03ac7d79-02b7-4bee-d318-9731413bf97b@mellanox.com>
        <CAJieiUhNV7=r53mmsHTHAmA8g0PKoxszHyNMXwYKG4OsB20KjQ@mail.gmail.com>
        <b04f5f7e-dca1-b219-eb52-03f58fd3823e@mellanox.com>
        <CAJieiUgwRT8NbNdZ37HXJn9OYc78bpj=Zb9N5pQQQ_SLZhD1kg@mail.gmail.com>
        <20170530134755.6675023c@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Bloch <markb@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Balki Raman <ramanb@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37270 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750946AbdE3LyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 07:54:25 -0400
In-Reply-To: <20170530134755.6675023c@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 May 2017 13:47:55 +0200, Jiri Benc wrote:
> On Mon, 29 May 2017 11:37:22 -0700, Roopa Prabhu wrote:
> > This code is also hit via the OVS path, and i don't see a problem with
> > your changes and analysis but i am not too familiar with the ovs call
> > path. I see that the relevant developers are CC'ed.
> 
> I don't see a problem with ovs and this patch. Ovs calls
> rtnl_delete_link.
> 
> I'd prefer to have the code in a vxlan_vs_del_dev function to be
> symmetrical with vxlan_vs_add_dev similarly to what Roopa suggested. If
> you keep me in CC while resending I'll be happy to add my ack to the
> patch.

I replied to a wrong email in the thread but I guess it's obvious what
I wanted to reply to :-)

Sorry for that,

 Jiri
