From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference in xt_register_target()
Date: Wed, 05 Sep 2012 17:55:06 +0200
Message-ID: <1346860506.13121.148.camel@edumazet-glaptop>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-05 at 23:43 +0800, Cong Wang wrote:
> Hi, folks,
> 
> The latest net-next tree can't boot due to a NULL ptr def
> bug in the kernel, the full backtrack is:
> 
> http://img1.douban.com/view/photo/photo/public/p1697139550.jpg
> 
> the kernel .config file is:
> 
> http://pastebin.com/9YTnkqKN
> 
> I don't have time to look into the issue. If you need other info,
> please let me know.

It seems xt_nat_init() is called before xt_init(), so xt array is not
yet setup.



