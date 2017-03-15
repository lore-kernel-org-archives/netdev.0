From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: sun: sungem: rix a possible null dereference
Date: Wed, 15 Mar 2017 22:45:03 +0100
Message-ID: <CAC=8w91tNO1LM23V=vp4spS9QGKwMCB1T7HVM7=r1WOfH_XOSQ@mail.gmail.com>
References: <1489526601-9423-1-git-send-email-tremyfr@gmail.com> <88708a0d-7b8a-b1d7-ee66-fd51c6bfe0fe@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        dan.carpenter@oracle.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <88708a0d-7b8a-b1d7-ee66-fd51c6bfe0fe@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On 3/15/17, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
> Hello!
>
> On 3/15/2017 12:23 AM, Philippe Reynes wrote:
>
>> The function gem_begin_auto_negotiation dereference
>> the pointer ep before testing if it's null. This
>> patch add a check on ep before dereferencing it.
>>
>> This issue was added by the patch 92552fdd557:
>> "net: sun: sungem: use new api ethtool_{get|set}_link_ksettings".
>
>     There's Fixes: tag for that now, described in
> Documentation/process/submitting-patches.rst...

Thanks a lot for pointing me this tag.
I'm sending a v2 of this patch with this tag.

>> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> [...]
>
> MBR, Sergei
>

Thanks,
Philippe
