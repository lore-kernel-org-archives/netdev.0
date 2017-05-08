From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next ] tcp: add new parameter tcp_inherit_buffsize
 to control the initial buffer size for new passive connetion
Date: Mon, 08 May 2017 07:46:27 -0700
Message-ID: <1494254787.7796.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAPYxyxJYXA_maME_qnshnFdzwDUkU1PvgDBQMfH32EerfQJZxA@mail.gmail.com>
         <1493737515.31837.42.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAPYxyxJBPO6W_wjYwXZQ5DS0sFjLh+A_GPSz1qn6qRZkqhMFQQ@mail.gmail.com>
         <1493992346.7796.43.camel@edumazet-glaptop3.roam.corp.google.com>
         <c42195b5-7c77-fb8d-9ea6-214ad762aab8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33135 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754315AbdEHOqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:46:31 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so10956835pgc.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 07:46:30 -0700 (PDT)
In-Reply-To: <c42195b5-7c77-fb8d-9ea6-214ad762aab8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-08 at 15:49 +0800, Shan Wei wrote:

> Indeed,  HZ=250.  What is the problem about autotuning with HZ=250?
> 

You might look at recent patches.

commit 645f4c6f2ebd040688cc2a5f626ffc909e66ccf2
("tcp: switch rcv_rtt_est and rcvq_space to high resolution timestamps")

Thanks.
