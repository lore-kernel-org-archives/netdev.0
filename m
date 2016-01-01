From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/nfc: GPF in llcp_sock_getname
Date: Fri, 1 Jan 2016 15:28:53 -0800
Message-ID: <CAM_iQpWYqhOQZWB0Oo=Oa2GWGhy_HxunfpEPzjwha3iz9jJ9UQ@mail.gmail.com>
References: <CACT4Y+baorktL_dBHEWcz_jHYTzhM_-DJoms81bzVx8FbYk63w@mail.gmail.com>
	<CAM_iQpX-vHywG6DJb=5wLCouNAXXqA1wo=tKJ1S78MDyZfkNCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpX-vHywG6DJb=5wLCouNAXXqA1wo=tKJ1S78MDyZfkNCw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 1, 2016 at 12:58 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> It looks like we forget to initialize ->service_name_len
> and ->servicce_name before bind().

Never mind, __GFP_ZERO is passed in sk_alloc()...
