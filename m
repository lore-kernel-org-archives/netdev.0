From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Thu, 15 May 2014 10:39:20 -0700
Message-ID: <CAM_iQpU84BD4WjTEW0Yn6-R3ocHh25quAj_F8cmkVK=CRZd9Kg@mail.gmail.com>
References: <20140515164703.73a1cf06@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140515164703.73a1cf06@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2014 at 11:47 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (powerpc
> allnoconfig) produced this warning:
>
>
> include/net/ip.h:211:5: warning: "CONFIG_SYSCTL" is not defined [-Wundef]
>  #if CONFIG_SYSCTL
>      ^
>
> Introduced by commit 122ff243f5f1 ("ipv4: make ip_local_reserved_ports
> per netns").


Oops, blame my fat fingers... Just s/#if/#ifdef/. ;)
