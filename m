From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v4 0/3] net: mpls: fragmentation and gso fixes
 for locally originated traffic
Date: Mon, 29 Aug 2016 14:07:30 +0200
Message-ID: <20160829120729.GA25359@penelope.isobedori.kobe.vergenet.net>
References: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
 <20160826.114137.1990982027647137057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        buytenh@wantstofly.org, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36348 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932628AbcH2MHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 08:07:34 -0400
Received: by mail-wm0-f54.google.com with SMTP id q128so75667750wma.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 05:07:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160826.114137.1990982027647137057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 11:41:37AM -0700, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed, 24 Aug 2016 20:10:42 -0700
> 
> > This series fixes mtu and fragmentation for tunnels using lwtunnel
> > output redirect, and fixes GSO for MPLS for locally originated traffic
> > reported by Lennert Buytenhek.
> > 
> > A follow on series will address fragmentation and GSO for forwarded
> > MPLS traffic. Hardware offload of GSO with MPLS also needs to be
> > addressed.
> > 
> > Simon: Can you verify this works with OVS for single and multiple
> >        labels?
> 
> Simon, I'm waiting on your testing before I apply this series.

Sorry for the delay. I will test it ASAP.
