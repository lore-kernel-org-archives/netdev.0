From: SeongJae Park <sj38.park@gmail.com>
Subject: Re: [PATCH] ixen-netback: fix trivial printf format build warning
Date: Thu, 27 Mar 2014 03:51:56 +0900
Message-ID: <CAEjAshoKmsbsUBJ-EzfaXwncNaxtsJCM+p_h92t3SZ+FAHEKsA@mail.gmail.com>
References: <1395806210-23528-1-git-send-email-sj38.park@gmail.com>
 <1395828547.22808.28.camel@kazak.uk.xensource.com> <CAEjAshoYWeCdVD9mC4f6EQkQkd-dVuk47gGEZ-4ig-uVS938ag@mail.gmail.com>
 <20140326.144613.1346051389108269225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian.Campbell@citrix.com, trivial@kernel.org, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140326.144613.1346051389108269225.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 3:46 AM, David Miller <davem@davemloft.net> wrote:
> From: SeongJae Park <sj38.park@gmail.com>
> Date: Wed, 26 Mar 2014 19:34:21 +0900
>
>> Thank you for let me know kindly :)
>
> Also your fix wasn't correct.
>
> You changed the code to use %lx but the type isn't a long.
>
> It's the difference between two pointers, which is ptrdiff_t.  The
> proper printf format string for a hexadecimal ptrdiff_t is %tx

You're right. Thanks for pointing that.
