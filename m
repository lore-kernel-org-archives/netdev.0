From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Namespaceify tcp_fastopen knob
Date: Wed, 13 Sep 2017 06:02:59 -0700
Message-ID: <1505307779.15310.157.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505301598-12681-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
         <1505306674.15310.155.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Luca BRUNO <lucab@debian.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505306674.15310.155.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-13 at 05:44 -0700, Eric Dumazet wrote:
> On Wed, 2017-09-13 at 19:19 +0800, Haishuang Yan wrote:
> > Different namespace application might require enable TCP Fast Open
> > feature independently of the host.
> > 
> 
> Poor changelog, no actual description / list of sysctls that are moved
> to per netns.
> 
> And looking at the patch, it seems your conversion is not complete.
> 
> So I will ask you to provide more evidence that you tested your patch
> next time you submit it.

I suggest you move one sysctl at a time, in a patch series.

It will be easier to document and test for you, and review for us.

Thanks.
