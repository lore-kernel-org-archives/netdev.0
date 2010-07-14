From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Wed, 14 Jul 2010 00:27:56 -0300
Message-ID: <AANLkTikkcaionMp3SJLgo3JmCjxQ7rPZv3-3_RbxCx_4@mail.gmail.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	<1278626921.2435.73.camel@edumazet-laptop>
	<AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<4C395459.6080407@redhat.com>
	<1278835332.2538.51.camel@edumazet-laptop>
	<AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	<AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
	<AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
	<1279032023.2634.384.camel@edumazet-laptop>
	<AANLkTilrIByt4xAHhsBsKo3nDfv0_c3sF-dCiTiYiPnu@mail.gmail.com>
	<1279036193.2634.468.camel@edumazet-laptop>
	<AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
	<1279077678.2444.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279077678.2444.95.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mr. Dumazet,

2010/7/14 Eric Dumazet <eric.dumazet@gmail.com>:
> RDX being the sk pointer (and sk+0x38 contains the corrupted "sk_prot=
" value)
> , we notice RBP contains same "sk" value + 0x200000 =A0(2 Mbytes).
>
> (same remark on your initial bug report)
>
> Could you enable CONFIG_FRAME_POINTER=3Dy in your config ?

I can, but my bosses will kick my ass if I bring down the ISP again :)

If you think it's the only way to find the problem I'll tell them that
I need to do it. In this case, please tell me what other config
options/tools I can use to get as much info as possible...since I'll
probably be able to test this only once more on the production
environment for debugging purposes.

Cheers,

=46elipe Damasio
