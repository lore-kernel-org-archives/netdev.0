From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: fix spurious timestamping callbacks
Date: Sat, 23 Apr 2016 17:55:32 -0700
Message-ID: <1461459332.7627.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461436546.7627.45.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAJ3xEMg3HwbZG6qh5=ydaUesQX_goRSD6H_LowsEuW46TVDnbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36280 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbcDXAzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 20:55:36 -0400
Received: by mail-ig0-f172.google.com with SMTP id f1so47608074igr.1
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 17:55:35 -0700 (PDT)
In-Reply-To: <CAJ3xEMg3HwbZG6qh5=ydaUesQX_goRSD6H_LowsEuW46TVDnbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-23 at 23:23 +0300, Or Gerlitz wrote:
> On Sat, Apr 23, 2016 at 9:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > When multiple skb are TX-completed in a row, we might incorrectly keep
> > a timestamp of a prior skb and cause extra work.
> >
> > Fixes: ec693d47010e8 ("net/mlx4_en: Add HW timestamping (TS) support")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Willem de Bruijn <willemb@google.com>
> 
> Eric, was that supposed to be Reported-by: or Signed-off-by: ...

This was meant to be.

Cc: Willem de Bruijn <willemb@google.com>

Willem was CC on the original bug at Google (Google-Bug-Id: 28356763 )

Thanks.
