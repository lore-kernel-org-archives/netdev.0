From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: Replace explicit NULL comparisons
Date: Sat, 8 Apr 2017 22:14:38 +0200
Message-ID: <20170408201438.GC2679@salvia>
References: <20170408172113.GA9352@arushi-HP-Pavilion-Notebook>
 <nycvar.YFH.7.76.1704082020530.14011@n3.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53568 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752415AbdDHUOp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 16:14:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9E2F02493A
        for <netdev@vger.kernel.org>; Sat,  8 Apr 2017 22:14:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 405E0DA725
        for <netdev@vger.kernel.org>; Sat,  8 Apr 2017 22:14:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 66726DA862
        for <netdev@vger.kernel.org>; Sat,  8 Apr 2017 22:14:42 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1704082020530.14011@n3.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 08, 2017 at 08:21:56PM +0200, Jan Engelhardt wrote:
> On Saturday 2017-04-08 19:21, Arushi Singhal wrote:
> 
> >Replace explicit NULL comparison with ! operator to simplify code.
> 
> I still wouldn't do this, for the same reason as before. Comparing to 
> NULL explicitly more or less gave an extra guarantee that the other 
> operand was also a pointer.

Arushi, where does it say in the coding style that this is prefered?
