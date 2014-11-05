From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] bridge: include in6.h in if_bridge.h for struct in6_addr
Date: Tue, 4 Nov 2014 16:39:59 -0800
Message-ID: <CAM_iQpX-V60iTHBz3nFnJkNbEy1JvGkxu_8T1mwYYwd67WxBYA@mail.gmail.com>
References: <1415128881-30183-1-git-send-email-gregory.0xf0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	carlos@redhat.com, eblake@redhat.com,
	Kumar Gala <galak@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
To: Gregory Fong <gregory.0xf0@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415128881-30183-1-git-send-email-gregory.0xf0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 11:21 AM, Gregory Fong <gregory.0xf0@gmail.com> wrote:
> if_bridge.h uses struct in6_addr ip6, but wasn't including the in6.h
> header.  Thomas Backlund originally sent a patch to do this, but this
> revealed a redefinition issue: https://lkml.org/lkml/2013/1/13/116
>
> The redefinition issue should have been fixed by the following Linux
> commits:
> ee262ad827f89e2dc7851ec2986953b5b125c6bc inet: defines IPPROTO_* needed for module alias generation
> cfd280c91253cc28e4919e349fa7a813b63e71e8 net: sync some IP headers with glibc
>
> and the following glibc commit:
> 6c82a2f8d7c8e21e39237225c819f182ae438db3 Coordinate IPv6 definitions for Linux and glibc
>
> so actually include the header now.
>
> Reported-by: Colin Guthrie <colin@mageia.org>
> Reported-by: Christiaan Welvaart <cjw@daneel.dyndns.org>
> Reported-by: Thomas Backlund <tmb@mageia.org>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>


Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for working on it!
