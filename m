From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCHv2 net-next] net: filter: move load_pointer() into filter.h
Date: Thu, 3 Jul 2014 10:23:25 -0700
Message-ID: <CAMEtUuyVrzBM8eUo731MrNbQmSwZx9x5QkgoAqtXpi0xruif0w@mail.gmail.com>
References: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:53640 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbaGCRX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 13:23:26 -0400
Received: by mail-we0-f169.google.com with SMTP id t60so590932wes.14
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 10:23:25 -0700 (PDT)
In-Reply-To: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 3, 2014 at 7:56 AM, Zi Shen Lim <zlim.lnx@gmail.com> wrote:
> load_pointer() is already a static inline function.
> Let's move it into filter.h so BPF JIT implementations can reuse this
> function.
>
> Since we're exporting this function, let's also rename it to
> bpf_load_pointer() for clarity.
>
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
