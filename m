From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 10:30:38 -0700
Message-ID: <ec46025d-4618-499c-72fe-693da9abc050@gmail.com>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620140140.GB12383@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35710 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751085AbdFTRaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:30:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id z45so19048239wrb.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 10:30:52 -0700 (PDT)
In-Reply-To: <20170620140140.GB12383@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2017 07:01 AM, Andrew Lunn wrote:
> On Tue, Jun 20, 2017 at 10:06:54AM +0200, John Crispin wrote:
>> RPS and probably other kernel features are currently broken on some if not
>> all DSA devices. The root cause of this that skb_hash will call the
>> flow_disector.
> 
> Hi John
> 
> What is the call path when the flow_disector is called? I'm wondering
> if we can defer this, and call it later, after the tag code has
> removed the header.

Would not you usually want to configure RPS at the DSA network device
level where the switch tag has already been popped and you are
processing a regular Ethernet frame at that point?
-- 
Florian
