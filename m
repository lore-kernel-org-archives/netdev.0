From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC V3 PATCH 03/26] net/netpolicy: get device queue irq
 information
Date: Mon, 12 Sep 2016 19:48:46 +0300
Message-ID: <665fd0a7-fe83-742a-28fd-d597b28505b5@cogentembedded.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
 <1473692159-4017-4-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473692159-4017-4-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/12/2016 05:55 PM, kan.liang@intel.com wrote:

> From: Kan Liang <kan.liang@intel.com>
>
> Net policy needs to know device information. Currently, it's enough to
> only get irq information of rx and tx queues.
>
> This patch introduces ndo ops to do so, not ethtool ops.
> Because there are already several ways to get irq information in
> userspace. It's not necessory to extend the ethtool.

    Necessary.

> Signed-off-by: Kan Liang <kan.liang@intel.com>

[...]

MBR, Sergei
