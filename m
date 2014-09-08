From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Mon, 8 Sep 2014 15:21:52 -0700
Message-ID: <CAHA+R7PhH+oiKuxeYGJxVS3qP-qe_GEV4qSz0b+Gj-JpTcPGJw@mail.gmail.com>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
	<CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
	<CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>, netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:44734 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754928AbaIHWVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 18:21:53 -0400
Received: by mail-lb0-f178.google.com with SMTP id c11so2206668lbj.9
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 15:21:52 -0700 (PDT)
In-Reply-To: <CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 7, 2014 at 2:24 AM, Li RongQing <roy.qing.li@gmail.com> wrote:
> On Sun, Sep 7, 2014 at 11:44 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>> The operation of atomic maybe faster than spin lock.
>>
>> What is reason for this change?
>
> 1.  The operation of atomic maybe faster than spin lock
> 2.  I did not find that tx_dropped/tx_error/.. is protected by spin
> lock under net dir,
> sometime tx_dropped is atomic_long_t; sometime it is percpu variable;
> sometime it is
> u64,but does not need to protect.

I didn't dig the history of the code, why not use u64_stats_sync though?
