From: Adel Fuchs <adelfuchs@gmail.com>
Subject: running an eBPF program
Date: Fri, 26 May 2017 14:00:31 +0300
Message-ID: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:33934 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935988AbdEZLAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 07:00:33 -0400
Received: by mail-ua0-f169.google.com with SMTP id u10so4019005uaf.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 04:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I'm trying to run this eBPF program:

https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/tree/examples/bpf


and I get this error:


:~/iproute2/examples/bpf$sudo tc filter add dev enx00e11100329b parent
1: bpf obj bpf.o exp /tmp/bpf-uds flowid 1:1 action bpf obj bpf.o sec
action-mark            action bpf obj bpf.o sec action-rand ok

[sudo] password for adel:



Prog section 'classifier' rejected: Permission denied (13)!

- Type:         3

- Instructions: 218 (0 over limit)

- License:      GPL



Verifier analysis:



0: (bf) r6 = r1

1: (18) r9 = 0xffe0000e

3: (69) r0 = *(u16 *)(r6 +16)

invalid bpf_context access off=16 size=2



Error fetching program/map!

Failed to retrieve (e)BPF data!


Any suggestions?

Thanks,

Adel
