From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH net] tcp: Fix TLP implementation in case receive window
 limits send
Date: Wed, 24 Sep 2014 12:00:02 -0700
Message-ID: <CAB_+Fg69V2msVt3dr76VrgdYBOivjsRnvwBAuSWpi-v7Jkd+6Q@mail.gmail.com>
References: <6cbd68ba1ef44c5ca4b21bd3f65846af@AM3PR06MB388.eurprd06.prod.outlook.com>
	<CAK6E8=fQjqXbbbdCVR-yNBif7C7GRBnPNsq11V7QZbqgb7dtwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Itzcak Pechtalt <itzcak@flashnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:58734 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbaIXTAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 15:00:02 -0400
Received: by mail-ob0-f176.google.com with SMTP id wp18so5461108obc.21
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 12:00:02 -0700 (PDT)
In-Reply-To: <CAK6E8=fQjqXbbbdCVR-yNBif7C7GRBnPNsq11V7QZbqgb7dtwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, Sep 23, 2014 at 9:28 AM, Itzcak Pechtalt
> <itzcak@flashnetworks.com> wrote:
>> From: Itzcak Pechtalt <itzcak@flashnetworks.com>
>>
>> TCP Tail loss probe (TLP) algorithm implementation has some problem.
>> According to paper (draft-dukkipati-tcpm-tcp-loss-probe-0 ):
>> In case recive window of receiver limits send of new packet in probe time than
>> a retransmit of last packet send should be done.
>>
>> Actually, return code from tcp_write_xmit is not checked and only RTO is
>> scheduled,
>> So, it will take more time for reovery in this case than without TLP.
>>
>> Signed-off-by: Itzcak Pechtalt <itzcak@flashnetworks.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Nandita Dukkipati <nanditad@google.com>
