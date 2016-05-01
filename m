From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH net-next] ravb: Remove rx buffer ALIGN
Date: Sun, 1 May 2016 23:34:26 +0900
Message-ID: <CAH1o70JrqnBJfDvcrgpONnXpPPY1BtFW+tYVjAxcs8S-g_voNA@mail.gmail.com>
References: <1461514567-23444-1-git-send-email-ykaneko0929@gmail.com>
	<571FBE21.4050908@cogentembedded.com>
	<20160428233456.GC18128@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160428233456.GC18128@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon-san,

Thank you for testing this patch!

Thanks,
kaneko

2016-04-29 8:34 GMT+09:00 Simon Horman <horms@verge.net.au>:
> Hi Sergei, Hi Kaneko-san,
>
> On Tue, Apr 26, 2016 at 10:14:41PM +0300, Sergei Shtylyov wrote:
>> Hello.
>>
>> On 04/24/2016 07:16 PM, Yoshihiro Kaneko wrote:
>>
>> >From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> >
>> >Aligning the reception data size is not required.
>>
>>    OK, the gen 2/3 manuals indeed don't require this. I assume the patch has
>> been tested...
>
> This morning I tested this patch applied on net-next using the
> r8a7795/salvator-x  (Gen-3). My test was to boot to a user-space prompt
> using NFS root which was successful. I can run further tests on this setup
> if it would be useful.
>
> Unfortunately I do not have access to hardware to allow me to test this
> on Gen-2.
>
>> >Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> >Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
> Tested-by: Simon Horman <horms+renesas@verge.net.au>
>
>>    I have a few comments though...
>
> [...]
