From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Mon, 17 Oct 2011 11:03:54 +0300
Message-ID: <CAEnQRZCWBhTy24WkWoC_wy11YuLxWQ3GWr3v1=JcGvprq4AtmA@mail.gmail.com>
References: <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
	<1318586017-17207-1-git-send-email-mmaruseac@ixiacom.com>
	<1318596791.2223.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mihai Maruseac <mihai.maruseac@gmail.com>, davem@davemloft.net,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>, shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318596791.2223.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This assumes device ifindexes are contained in a small range
> [N .. N + X]
>
> I understand this can help some benchmarks, but in real world this wo=
nt
> help that much once ifindexes are 'fragmented' (If really this multi
> thousand devices stuff is for real)
>
> Listen, we currently have 256 slots in the hash table.
>
> Can we try to make 'offset' something like =A0(slot_number<<24) +
> (position in hash chain [slot_number]), instead of (position in devic=
es
> global list)


Eric, we can refine the idea of our first patch [1], where we recorded
the (bucket, offset) pair. Stephen, do you agree with this?


thanks,
Daniel.

[1] http://patchwork.ozlabs.org/patch/118331/
