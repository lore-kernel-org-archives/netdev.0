From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Mon, 2 Oct 2017 13:11:09 +0200
Message-ID: <CAHmME9pAvv7ebKC-uZGPJRi9Jasgrd2tgCvS1Lji+cgM1mV2qw@mail.gmail.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
 <f80d9afa-0ce2-903d-9bf9-b7bb8765086b@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, Mathias <mathias@hall-andersen.dk>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:47813 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750878AbdJBLLM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 07:11:12 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id dbb2c811
        for <netdev@vger.kernel.org>;
        Mon, 2 Oct 2017 11:01:29 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 15d57fff (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Mon, 2 Oct 2017 11:01:28 +0000 (UTC)
Received: by mail-oi0-f53.google.com with SMTP id w197so3819921oif.6
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 04:11:11 -0700 (PDT)
In-Reply-To: <f80d9afa-0ce2-903d-9bf9-b7bb8765086b@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 2, 2017 at 11:32 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> 1. Move the process to netns B, open the netlink socket and move back the
> process to netns A. The socket will remain in netns B and you will receive all
> netlink messages related to netns B.
>
> 2. Assign a nsid to netns B in netns A and use NETLINK_LISTEN_ALL_NSID on your
> netlink socket (see iproute2).

Both of these seem to rely on the process knowing where the device is
being moved and having access to that namespace. I don't think these
two things are a given though. Unless I'm missing something?

Jason
