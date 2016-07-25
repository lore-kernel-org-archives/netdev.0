From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Mon, 25 Jul 2016 21:57:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607252144220.1836@ja.home.ssi.bg>
References: <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg> <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn> <e0d3e238-312e-a0e2-9501-29beb7e2ef27@miraclelinux.com> <20160725.081349.445701096084716570.hchunhui@mail.ustc.edu.cn>
 <CAPA1RqD4Zf5k0HAZNbQCBcb36v6Rhj3PiQkMO+Dm_NUB=2d8Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-200700165-1469473026=:1836"
Cc: Chunhui He <hchunhui@mail.ustc.edu.cn>,
	David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	rshearma@brocade.com, dbarroso@fastly.com, martinbj2008@gmail.com,
	rick.jones2@hp.com, koct9i@gmail.com, edumazet@google.com,
	tgraf@suug.ch, ebiederm@xmission.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	network dev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPA1RqD4Zf5k0HAZNbQCBcb36v6Rhj3PiQkMO+Dm_NUB=2d8Gw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-200700165-1469473026=:1836
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Mon, 25 Jul 2016, 吉藤英明 wrote:

> OK, following blocks are "no-op" and we will get same result.
> 
> Well, please do not try changing several things at the same time and
> you could say:
> 
> if (ladder == neigh->ha && new == NUD_STALE &&
>     !(flags & NUD_UPDATE_F_ADMIN))
>         new = old;

	OK, lets do it with 2 patches then.

	Chunhui He, can you modify your patch to delete the
both lines and explain that we prefer to resolve the
remote address, even while remote packets try to set NUD_STALE
state. If your patch is accepted, I'll post second patch that
adds the line with the ADMIN check. As result, the code will
look like the example from Yoshifuji Hideaki above.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-200700165-1469473026=:1836--
