From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: netfilter: Remove multiple assignment.
Date: Mon, 27 Mar 2017 15:09:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFBAC5F@AcuExch.aculab.com>
References: <20170325124946.GA9109@arushi-HP-Pavilion-Notebook>
 <20170327120827.GA15676@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "outreachy-kernel@googlegroups.com"
        <outreachy-kernel@googlegroups.com>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
        Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:61650 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752297AbdC0PKB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 11:10:01 -0400
In-Reply-To: <20170327120827.GA15676@salvia>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 27 March 2017 13:08
> On Sat, Mar 25, 2017 at 06:19:47PM +0530, Arushi Singhal wrote:
> > This patch removes multiple assignments.
> > Done using coccinelle.
> > @@
> > identifier i1,i2;
> > constant c;
> > @@
> > - i1=i2=c;
> > + i1=c;
> > + i2=c;
> 
> You have to explain why this is bad.

And your substituted code isn't equivalent.
The correct replacement is:
	i2 = c;
	i1 = i2;

	David
