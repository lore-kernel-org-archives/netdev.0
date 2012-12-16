From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 05:22:13 -0500
Message-ID: <50CDA0D5.5080209@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-15 06:06 PM, Jan Engelhardt wrote:

> If I try that command (substituting ipt->xt and eth0->dummy0,
> ifb0->dummy1), all I get is the dreaded "Invalid argument".
> So the kernel rejected the command, which could indicate that
> userspace construction might have been ok.
>
> # tc filter add dev dummy0 parent ffff: protocol ip u32 match u32 0 0 \
> action xt -j CONNMARK action mirred egress redirect dev dummy1
>
> tablename: mangle hook: NF_IP_PRE_ROUTING
>          target:  CONNMARK and 0x0 index 0
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
>

No problem sending it to the kernel here on ubuntu 12.04.
I also upgraded to current linus git tree, same result.
The problem is the parameters are not accepted in user space as
you can see for connmark and what gets sent (eg CONNMARK and 0x0)
doesnt seem sensible.

> What was the last combination that worked?

First time this got reported to me (or i got CCed on the problem) - I am 
told it broke after iptables 1.4.11.

cheers,
jamal
