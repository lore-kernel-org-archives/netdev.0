From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 09:42:44 -0800
Message-ID: <cae599d5-fee9-1d39-914f-0f5145c04da4@hpe.com>
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
Received: from g4t3426.houston.hpe.com ([15.241.140.75]:3682 "EHLO
        g4t3426.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933417AbcKQRmr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:42:47 -0500
In-Reply-To: <20161117091638.5fab8494@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 12:16 AM, Jesper Dangaard Brouer wrote:
>> time to try IP_MTU_DISCOVER ;)
>
> To Rick, maybe you can find a good solution or option with Eric's hint,
> to send appropriate sized UDP packets with Don't Fragment (DF).

Well, I suppose adding another setsockopt() to the data socket creation 
wouldn't be too difficult, along with another command-line option to 
cause it to happen.

Could we leave things as "make sure you don't need fragmentation when 
you use this" or would netperf have to start processing ICMP messages?

happy benchmarking,

rick jones
