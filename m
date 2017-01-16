From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: Re: [PATCH for bnxt_re V3 03/21] bnxt_re: register with the NIC driver
Date: Mon, 16 Jan 2017 13:38:40 +0530
Message-ID: <CA+sbYW2SMbExwyw20TZtn3U13fkJvKCs5P8w5LdovN4Q3u0sjg@mail.gmail.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
 <1482225211-22423-4-git-send-email-selvin.xavier@broadcom.com> <20170115194143.GE20392@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:36312 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdAPIIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 03:08:41 -0500
Received: by mail-qt0-f181.google.com with SMTP id k15so97633325qtg.3
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 00:08:41 -0800 (PST)
In-Reply-To: <20170115194143.GE20392@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 1:11 AM, Leon Romanovsky <leon@kernel.org> wrote:
> Recently, in one of our submission to netdev and rdma, we got
> a reminder that inline functions shouldn't be in *.c. Let for
> the compiler to decide.
>
> IMHO, it should be open-coded without wrappers and honestly I failed to
> understand why do you need so many wrappers for one line standard kernel
> functions.

Agreed. During the initial days of development, we had some debug code also
inside these wrapper functions. Since the debug code was removed before upstream
submission, this function ended up as a wrapper for standard kernel function.
It makes perfect sense to knock off these wrapper functions. I will
queue it for next
clean-up/bug fix patch series.

Thanks
