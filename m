From: Nicolai Stange <nicstange@gmail.com>
Subject: Re: [PATCH] lib: test_bpf: purge CPP register redefinitions
Date: Mon, 22 Jun 2015 15:47:12 +0200
Message-ID: <87egl3lusf.fsf@gmail.com>
References: <87twu0df3k.fsf@gmail.com>
	<20150622060523.GA16156@Alexeis-MacBook-Pro.local>
	<5587B0C7.8090507@nod.at> <5587B4FB.3040609@nod.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolai Stange <nicstange@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel@iogearbox.net
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5587B4FB.3040609@nod.at> (Richard Weinberger's message of "Mon,
	22 Jun 2015 09:10:51 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Weinberger <richard@nod.at> writes:
> While riding the bus to my office I've materialized that idea.
> Nicolai, can you please give the attached patch a try?
W/o my test_bpf patch applied, w/ your patch applied:
 - linux mainline: um compiles
 - linux-next: um compiles up to this mfd/syscon issue communicated to
               you in sidechannel

In particular, your patch fixes, next to [0], the issue addressed by my
patch.

-> My 1K line regexp replace patch reduces to a debatable naming style
   patch. Drop it, sorry for the noise.

[0] http://lkml.kernel.org/r/1420386535-22530-1-git-send-email-richard@nod.at
