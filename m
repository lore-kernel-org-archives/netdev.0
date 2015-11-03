From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Resource leak in unshare
Date: Mon, 02 Nov 2015 17:16:44 -0800
Message-ID: <1446513404.23275.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
	 <87oafcrzsa.fsf@x220.int.ebiederm.org>
	 <1446494052.23275.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446508987.23275.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446512899.23275.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Vyukov <dvyukov@google.com>, nicolas.dichtel@6wind.com,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446512899.23275.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 17:08 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

Erm, patch title would be :

[PATCH] sit: fix sit0 percpu double allocations
