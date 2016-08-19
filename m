From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v2 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Fri, 19 Aug 2016 23:57:11 +0200
Message-ID: <20160819215711.kop6qsjzkfvtlhxp@alphalink.fr>
References: <1471347218-24472-1-git-send-email-fgao@ikuai8.com>
 <20160817174219.y4opmhj4u77m3ufq@alphalink.fr>
 <CA+6hz4qROeAKSgQJ-tf3qaDp5zBqssq4gV39wqyUT0ctp1DHcg@mail.gmail.com>
 <20160818161315.6wnv45tzw6v5napa@alphalink.fr>
 <CA+6hz4ouOtMpxxiTOx99EeOtbZZa_L4c7EprPEPoxVpP5rbTGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <fgao@ikuai8.com>, paulus@samba.org,
        linux-ppp@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+6hz4ouOtMpxxiTOx99EeOtbZZa_L4c7EprPEPoxVpP5rbTGQ@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2016 at 06:52:58AM +0800, Feng Gao wrote:
> Hi Guillaume,
> 
> Thanks your detail analyses.
> Now I think it is a good solution that just drop the packet and print
> error log instead my original solution that supports reentrant. This
> solution will not bring any side effects.
> 
At least it should improve the situation.
I'm still uncomfortable with this approach because it only fixes part
of the problem. But I have nothing better to propose for now.
