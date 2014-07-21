From: Willem de Bruijn <willemb@google.com>
Subject: Re: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Mon, 21 Jul 2014 18:36:48 -0400
Message-ID: <CA+FuTSdaZ+xw1Kj6j2VZSuT0ArOG92gPn54Hrz_eSJHOvQ0yhQ@mail.gmail.com>
References: <53CD1326.5090006@ng4t.com> <53CD1AE5.10408@redhat.com>
 <53CD2661.8070707@ng4t.com> <53CD2E08.7070204@redhat.com> <20140721203253.Horde.9bpg4-qQqIsddySIO6hXOw1@ssl.lux01.de>
 <CA+FuTScUC08D_+iHwxVuvWBSDdKgT7bQv-sigwAiopFodFOc=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: mihail.dakov@ng4t.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:52997 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbaGUWhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:37:19 -0400
Received: by mail-vc0-f171.google.com with SMTP id hq11so11941028vcb.30
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:37:18 -0700 (PDT)
In-Reply-To: <CA+FuTScUC08D_+iHwxVuvWBSDdKgT7bQv-sigwAiopFodFOc=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>     {BPF_JMP | BPF_JEQ, 1, 0, PACKET_OUTGOING},
>     {BPF_RET, 0, 0, 0x00000000},
>     {BPF_RET, 0, 0, 0x0000ffff},

Small error: the condition has to be inverted for your use case. This
filters out only outgoing packets.
