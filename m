From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH net-next] ravb: ptp: fix misplaced ravb_ptp_stop() calling
 in ravb_probe()
Date: Mon, 14 Dec 2015 00:39:59 +0900
Message-ID: <CAH1o70KogcskpKP+yx3A52c3spAakroRiAuRfi4HkkQq0NguHA@mail.gmail.com>
References: <1449599969-20628-1-git-send-email-ykaneko0929@gmail.com>
	<566838CB.10500@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <566838CB.10500@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-12-09 23:20 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/8/2015 9:39 PM, Yoshihiro Kaneko wrote:
>
>> 'commit <f5d7837f96e5> ("ravb: ptp: Add CONFIG mode support")' added
>> a calling of ravb_ptp_stop() in a wrong place in ravb_probe().
>>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
>
>    Well, this patch is good to apply anyway:

I thought that the interrupt should be disabled before freeing memory.
anyway, thanks.

>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> MBR, Sergei
>
