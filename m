From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Thu, 28 Jan 2016 21:36:02 +0300
Message-ID: <56AA5F92.5030901@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <20160126002300.GA27856@verge.net.au> <56A7C252.3040707@cogentembedded.com>
 <20160127014944.GD27499@verge.net.au> <56AA38C5.6070004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <56AA38C5.6070004@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2016 06:50 PM, Sergei Shtylyov wrote:

>>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
>     Kaneko-san, with the amount of the review changes, it might make sense for
> you to assume the authorship of this patch, only noting it's based on
> Mizuguchi-san's work. In principle, when you change the original patch, you
> should document the changes you made in the change log, above ---...
>
>>>>> This patch supports the following interrupts.
>>>>>
>>>>> - One interrupt for multiple (descriptor, error, management)
>>>>> - One interrupt for emac
>>>>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>>>>
>>>>> This patch improve efficiency of the interrupt handler by adding the
>>>>> interrupt handler corresponding to each interrupt source described
>>>>> above. Additionally, it reduces the number of times of the access to
>>>>> EthernetAVB IF.
>>>>>
>>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>>>
>>>> I have tested this patch and the result seems positive.
>>>
>>>     Tested on gen3 only I guess?
>>
>> Yes, that is correct.
>>
>>>> Please let me know if any more/different testing would help.
>>>
>>>     Sanity testing on some gen2 SoC wouldn't hurt (if you have time).
>>
>> I don't believe that I have access to a gen2 board (+ extra hardware ?)
>> where ravb works.
>
>     Sorry, I just forgot about that.
>
>> If you do would it be possible for you to do a sanity test?
>
>     Yes, of course.

    Oops, I forgot that I failed to make the driver work on Porter -- it fails 
to connect to PHY while opening eth<n>. I've tested the patch as far as I 
could and it didn't blow up. :-)
    I'll have access to the other board (most probably Alt) next week.

MBR, Sergei

