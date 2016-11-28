From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Mon, 28 Nov 2016 10:33:49 -0800
Message-ID: <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
References: <20140903165943.372b897b@redhat.com>
 <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:53840 "EHLO
        g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753809AbcK1Sdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 13:33:51 -0500
In-Reply-To: <20161117091638.5fab8494@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 12:16 AM, Jesper Dangaard Brouer wrote:
>> time to try IP_MTU_DISCOVER ;)
>
> To Rick, maybe you can find a good solution or option with Eric's hint,
> to send appropriate sized UDP packets with Don't Fragment (DF).

Jesper -

Top of trunk has a change adding an omni, test-specific -f option which 
will set IP_MTU_DISCOVER:IP_PMTUDISC_DO on the data socket.  Is that 
sufficient to your needs?

happy benchmarking,

rick
