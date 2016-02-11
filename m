From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH=5D_veth=3A_don=E2=80=99t_modify_ip=5Fsummed=3B_doing_so?=
	=?UTF-8?Q?_treats_packets_with_bad_checksums_as_good=2E?=
Date: Thu, 11 Feb 2016 11:19:36 -0800
Message-ID: <CAKUBDd8q9s4bm-_Dq2skyXVYkfNW7Xg6QdyD9TiOui8oTV+-1w@mail.gmail.com>
References: <CAM_iQpUOKGoNNDF2Nbut8a0q2rGY6pCXBm3NVkBMe=63K7L9bg@mail.gmail.com>
 <1450467299-7188-1-git-send-email-vijayp@vijayp.ca> <20151222.151612.206719325623084440.davem@davemloft.net>
 <CAKUBDd83j1yL+HR24K+qdQBcN66BZ4U50Dj7H_STRrjHb85-zA@mail.gmail.com> <CAM_iQpVXzPWeM2AOkBGPO7dFQ6Jj1vyWou3ZTCq1qewq1KdwhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVXzPWeM2AOkBGPO7dFQ6Jj1vyWou3ZTCq1qewq1KdwhA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just as a followup, I wrote a short blog detailing the bug and our
resolution: (https://twitter.com/vijayp/status/697837808417779716)

Thanks again for your help in guiding us through our first kernel
patch. This was a great experience!

direct link: https://medium.com/vijay-pandurangan/linux-kernel-bug-delivers-corrupt-tcp-ip-data-to-mesos-kubernetes-docker-containers-4986f88f7a19#.aymvnbaa8

On Wed, Dec 23, 2015 at 9:57 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Dec 22, 2015 at 11:37 PM, Vijay Pandurangan <vijayp@vijayp.ca> wrote:
>> Cool, thanks! I see it in the -stable queue. Is there anything else I need
>> to do to help with getting this into main or backporting?  Happy to pitch in
>> if I can be helpful.
>>
>
> DaveM usually just backports it to a few recent stable tree, if you want
> to backport further, for example 3.14, you probably need to send
> the commit ID to Greg KH.
>
> Thanks.
