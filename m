From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 21:12:25 -0600
Message-ID: <c37a16c3-c8a3-2226-d18c-caeeb22bda39@cumulusnetworks.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
 <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
 <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
 <CAOrHB_Dw1MJnfeD034HzGWkMrzEhP6PUKGFP3jDJzeNyRSZcHg@mail.gmail.com>
 <350fc449-ae3a-8e48-8a09-6d95cfa9901e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34066 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754757AbcHYExi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 00:53:38 -0400
Received: by mail-pf0-f181.google.com with SMTP id p64so13961215pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 21:53:38 -0700 (PDT)
In-Reply-To: <350fc449-ae3a-8e48-8a09-6d95cfa9901e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/16 12:53 PM, David Ahern wrote:
> What change is needed in pop_mpls? It already resets the mac_header and if MPLS labels are removed there is no need to set network_header. I take it you mean if the protocol is still MPLS and there are still labels then the network header needs to be set and that means finding the bottom label. Does OVS set the bottom of stack bit? From what I can tell OVS is not parsing the MPLS label so no requirement that BOS is set. Without that there is no way to tell when the labels are done short of guessing.

I was confusing the inner network layer with the mpls network header. Just sent a v4. can you verify it works for single and multiple labels with OVS? 
