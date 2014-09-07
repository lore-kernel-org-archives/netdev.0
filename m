From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Sun, 7 Sep 2014 17:24:11 +0800
Message-ID: <CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
	<CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:61526 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaIGJYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 05:24:12 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so12566343qaq.38
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 02:24:11 -0700 (PDT)
In-Reply-To: <CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 7, 2014 at 11:44 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>> The operation of atomic maybe faster than spin lock.
>
> What is reason for this change?

1.  The operation of atomic maybe faster than spin lock
2.  I did not find that tx_dropped/tx_error/.. is protected by spin
lock under net dir,
sometime tx_dropped is atomic_long_t; sometime it is percpu variable;
sometime it is
u64,but does not need to protect.

-Roy
