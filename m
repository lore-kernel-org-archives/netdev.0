From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: net/sched: act_skbmod: rcu_read_unlock in tcf_skbmod_dump?
Date: Sat, 4 Mar 2017 18:46:32 -0500
Message-ID: <f9a9b434-ea38-3f7f-6207-8c7bc7317bc4@mojatatu.com>
References: <1488660579-3056-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36747 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752242AbdCDXrb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 18:47:31 -0500
Received: by mail-it0-f46.google.com with SMTP id h10so31871333ith.1
        for <netdev@vger.kernel.org>; Sat, 04 Mar 2017 15:46:35 -0800 (PST)
In-Reply-To: <1488660579-3056-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-03-04 03:49 PM, Alexey Khoroshilov wrote:
> Hello!
>
> rcu_read_unlock() in tcf_skbmod_dump() looks suspicious to me.

It does look suspicious. You want to send a patch or should I?

cheers,
jamal
