From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Tue, 26 Jan 2016 22:00:34 +0300
Message-ID: <56A7C252.3040707@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <20160126002300.GA27856@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Simon Horman <horms@verge.net.au>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20160126002300.GA27856@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

    Yoshihiro-san, there was no need to hurry -- net-next is still closed and 
by posting this patch to netdev you're only making DaveM upset...

On 01/26/2016 03:23 AM, Simon Horman wrote:

 >> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch supports the following interrupts.
>>
>> - One interrupt for multiple (descriptor, error, management)
>> - One interrupt for emac
>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>
>> This patch improve efficiency of the interrupt handler by adding the
>> interrupt handler corresponding to each interrupt source described
>> above. Additionally, it reduces the number of times of the access to
>> EthernetAVB IF.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
> I have tested this patch and the result seems positive.

    Tested on gen3 only I guess?

> Please let me know if any more/different testing would help.

    Sanity testing on some gen2 SoC wouldn't hurt (if you have time).

[...]

> Please feel free to add:
>
> Tested-by: Simon Horman <horms+renesas@verge.net.au>

    Thank you!

MBR, Sergei

