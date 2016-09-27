From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Tue, 27 Sep 2016 09:45:36 +0200
Message-ID: <20160927094536.392c5045@griffin>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
        <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
        <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
        <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
        <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
        <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
        <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
        <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
        <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
        <20160926175622.3b00d478@griffin>
        <20160926190259.3b878aa5@griffin>
        <363ba109-1951-1018-060f-25df33c717e0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
        Simon Horman <simon.horman@netronome.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751237AbcI0Hpo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 03:45:44 -0400
In-Reply-To: <363ba109-1951-1018-060f-25df33c717e0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Sep 2016 20:04:06 -0600, David Ahern wrote:
> you know this code better than me, but key_extract pulls the eth
> header and then sets network header. If MPLS labels are present then
> it is the labels that the network_header now points to. How did come
> to the conclusion it is after the labels?

Look ~100 lines below that, to "if (eth_p_mpls(key->eth.type))".
There's a while loop advancing network header.

 Jiri
