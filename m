From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC V3 PATCH 22/26] net/netpolicy: set per task policy by proc
Date: Mon, 12 Sep 2016 20:01:50 +0300
Message-ID: <9e899649-d646-f4e8-87ce-6aa60d23e6e8@cogentembedded.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
 <1473692159-4017-23-git-send-email-kan.liang@intel.com>
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
In-Reply-To: <1473692159-4017-23-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/12/2016 05:55 PM, kan.liang@intel.com wrote:

> From: Kan Liang <kan.liang@intel.com>
>
> Users may not want to change the source code to add per task net polic

    Policy?

> support. Or they may want to change a running task's net policy. prctl
> does not work for both cases.
>
> This patch adds an interface in /proc, which can be used to set and
> retrieve policy of already running tasks. User can write the policy name
> into /proc/$PID/net_policy to set per task net policy.
>
> Signed-off-by: Kan Liang <kan.liang@intel.com>

[...]

MBR, Sergei
