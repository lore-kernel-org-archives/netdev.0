From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v2] ipv6: fix a potential deadlock in do_ipv6_setsockopt()
Date: Thu, 20 Oct 2016 16:43:54 -0700
Message-ID: <CAM_iQpVOtqP9XtYuAcwm2ccdY+itKdH_mEnN71wGwYO4cTF8xg@mail.gmail.com>
References: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
 <1476971226.7065.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUvU8dZPquAgtcZASO6jhjtoYQ2nc8EBceqZmSHg4ZSsQ@mail.gmail.com> <1477001458.7065.37.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Baozeng Ding <sploving1@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:34891 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbcJTXoP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 19:44:15 -0400
Received: by mail-it0-f41.google.com with SMTP id 4so203295843itv.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 16:44:15 -0700 (PDT)
In-Reply-To: <1477001458.7065.37.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 3:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> I used 'I wonder if' to say that we might have some better way to code
> this test nowadays, but this can be done in a separate patch of course.

OK, let's keep one bugfix in one patch. ;)
