From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ipv6:Fix concurrent access issue in the function inet6_rtm_deladdr
Date: Tue, 4 Aug 2015 20:54:59 -0700
Message-ID: <CAHA+R7OvAjc0VKXR9w7TiRkqs-bU8AMKpoUONsBMWKSvVdEc0Q@mail.gmail.com>
References: <1438742340-28451-1-git-send-email-uboot477@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Nicholas Krause <xerofoify@gmail.com>
To: Nicholas Krause <uboot477@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438742340-28451-1-git-send-email-uboot477@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 4, 2015 at 7:39 PM, Nicholas Krause <uboot477@gmail.com> wrote:
> From: Nicholas Krause <xerofoify@gmail.com>
>
> This fixes the issue with conncurrent access when calling the function
> inte6_addr_del due to this function using non locked wrapper versions
> of certain functions by locking the routing mutex before and after this
> call with rtnl_lock/unlock. After the unlocking just return the error
> code as normal to signal success or failure to the caller of the function
> inet_6_rtm_addr.
>

Huh? Isn't inet6_rtm_deladdr() already called with rtnl lock?

What bug are you trying to fix?
