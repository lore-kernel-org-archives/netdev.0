From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Thu, 21 Sep 2017 07:56:39 -0700
Message-ID: <1506005799.29839.130.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
         <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
         <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
         <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
         <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl>
         <548a893c-8a8f-3b07-00f7-d75de1d777ad@itcare.pl>
         <7d8731ee-6c91-bbfd-6313-c95f52d7b49a@itcare.pl>
         <26e8b899-d8b1-caa4-436b-e23ffe384b0f@itcare.pl>
         <6c36fa00-13e6-8cd7-ff5c-df7739220736@itcare.pl>
         <CAEA6p_DpSr84cYu3pXqoHV=V=daSsbiOcnzsF+Kt0r4Wv_jmdg@mail.gmail.com>
         <CAEA6p_AiLvZxsyu+iOCrPzW-H28N=HBnWycy8w6gdZHFk2Q1dQ@mail.gmail.com>
         <1505956639.29839.108.camel@edumazet-glaptop3.roam.corp.google.com>
         <a016d5bc-1cbb-44d7-9ebf-e7e5428e6f98@itcare.pl>
         <1505991826.29839.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <8d2b4263-bd81-9cff-81ac-2df686cf29aa@itcare.pl>
         <80e8948e-669b-4139-add6-637c6dd3405f@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>, Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:47056 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751598AbdIUO4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 10:56:44 -0400
Received: by mail-pf0-f176.google.com with SMTP id r68so3336291pfj.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 07:56:43 -0700 (PDT)
In-Reply-To: <80e8948e-669b-4139-add6-637c6dd3405f@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-21 at 15:18 +0200, Paweł Staszewski wrote:

> ok after adding patch all is working from now for about 1 hour of normal 
> traffic witc all bgp sessions connected and about 600k prefixes in kernel.


Great, I am doing to submit an official patch, uniting skb_dst_force()
and skb_dst_force_safe() into a single helper.

Thanks.
