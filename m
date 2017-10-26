From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: i40e PF reset / WARNING: CPU: 3 PID: 3556 at drivers/net/ethernet/intel/i40e/i40e_txrx.c:1248
 i40e_setup_rx_descriptors+0x15/0xa9
Date: Thu, 26 Oct 2017 08:36:39 -0700
Message-ID: <CAKgT0Ucx+iji0LSJR6+=MmXxFd7PCCcJC4K=F4H+4VyQhvCfQQ@mail.gmail.com>
References: <420eaed2-cb76-d67c-cb85-f62d02c648fe@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        "e1000-devel@lists.sourceforge.net"
        <e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:54952 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932137AbdJZPgk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:36:40 -0400
Received: by mail-qt0-f196.google.com with SMTP id z19so4779029qtg.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:36:40 -0700 (PDT)
In-Reply-To: <420eaed2-cb76-d67c-cb85-f62d02c648fe@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 8:25 AM, Pawe=C5=82 Staszewski <pstaszewski@itcare.=
pl> wrote:
> Server after runing for about 40 hours is starting to loose all links on =
all
> nics.
>
> Warning from : Kernel 4.12.14
>
> Latest working kernel 4.11.12
>
> all kernels >4.14 - have same problem but less in debug info
>
>
> Below warning from 4.12.14.

Thanks for the update. I'm adding e1000-devel so we can track this for
Intel support.

We are looking into the issues you have reported. Please just add
these to the Bugzilla you already have open on the issue. No need to
start new threads on netdev.

It will likely take a while for us to resolve the issues you have seen
on 4.14 since we will need to work with our firmware team to
understand where the filtering resources are going.

- Alex
