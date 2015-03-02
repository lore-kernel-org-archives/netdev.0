From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] filter: refactor common filter attach code into __sk_attach_prog
Date: Mon, 2 Mar 2015 09:10:41 -0800
Message-ID: <CAMEtUux1VUxqB=0EEhSA1su6AnwxGNqoHyad+4LR6Ne7BS-yPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:47056 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbbCBRLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:11:02 -0500
Received: by mail-qg0-f44.google.com with SMTP id z107so5948069qgd.3
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 09:11:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 3:25 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Both sk_attach_filter() and sk_attach_bpf() are setting up sk_filter,
> charging skmem and attaching it to the socket after we got the eBPF
> prog up and ready. Lets refactor that into a common helper.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

tricky :) went few times of the code, since it felt that
there is memory leak, but finally got it, I think it all good.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
