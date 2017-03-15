From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sun: sungem: rix a possible null dereference
Date: Wed, 15 Mar 2017 13:05:24 +0300
Message-ID: <88708a0d-7b8a-b1d7-ee66-fd51c6bfe0fe@cogentembedded.com>
References: <1489526601-9423-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net,
        mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489526601-9423-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 3/15/2017 12:23 AM, Philippe Reynes wrote:

> The function gem_begin_auto_negotiation dereference
> the pointer ep before testing if it's null. This
> patch add a check on ep before dereferencing it.
>
> This issue was added by the patch 92552fdd557:
> "net: sun: sungem: use new api ethtool_{get|set}_link_ksettings".

    There's Fixes: tag for that now, described in 
Documentation/process/submitting-patches.rst...

> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
[...]

MBR, Sergei
