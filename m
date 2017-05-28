From: Adel Fuchs <adelfuchs@gmail.com>
Subject: Error with printk and bpf_trace_printk
Date: Sun, 28 May 2017 17:48:20 +0300
Message-ID: <CAErYV9EJtbgaWn4KAeoADxnHgj7S+vFdHgu78Y2PxNuhpWrANw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:35669 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdE1OsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 10:48:21 -0400
Received: by mail-vk0-f44.google.com with SMTP id w1so2078620vkd.2
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 07:48:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a working eBPF program, and I'm trying to add outputs to it.
I'm not able to use both printk and bpf_trace_printk functions. I get
this error:

ELF contains non-map related relo data in entry 0 pointing to section
8! Compiler bug?!

Prog section 'ingress' rejected: Invalid argument (22)!
 - Type:         3
 - Instructions: 16 (0 over limit)
 - License:      GPL

Verifier analysis:

0: (bf) r6 = r1
1: (18) r1 = 0x0
3: (85) call bpf_unspec#0
unknown func bpf_unspec#0

Error fetching program/map!
Failed to retrieve (e)BPF data!

Are there certain "includes" that I need to add?
In addition, I'm not sure I'm using the function correctly. I just
wrote: printk("hi")

Thanks!
Adel
