From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: ethtool -x full support
Date: Thu, 20 Oct 2016 07:26:27 -0700
Message-ID: <1476973587.7065.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
         <1476818655.5650.69.camel@edumazet-glaptop3.roam.corp.google.com>
         <BL2PR07MB2306E14F54D13CA215D8923C8DD50@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Ariel Elior <ariel.elior@qlogic.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35352 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964983AbcJTO0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 10:26:31 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so5750977pfj.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 07:26:30 -0700 (PDT)
In-Reply-To: <BL2PR07MB2306E14F54D13CA215D8923C8DD50@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-20 at 12:27 +0000, Mintz, Yuval wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > >
> > > Implement ethtool -x full support, so that rss key can be fetched
> > > instead of assuming it matches /proc/sys/net/core/netdev_rss_key
> > > content.
> > 
> > I'll send a V2, tested with CONFIG_BNX2X_SRIOV=y ;)
> > 
> 
> Hi Eric,
> 
> Thanks for this. Are you planning on sending v2 or do you want us to take over?
> 
> BTW, what's the benefit of changing the RSS keys? Giving the hash properties,
> in which scenarios would we gain by switching keys?

I will send a v2

Changing keys once a day or so might be important for security
purposes. 

I wont give details here ;)

Thanks.
