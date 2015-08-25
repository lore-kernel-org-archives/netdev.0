From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH repost net-next] net: compile renesas directory if
 NET_VENDOR_RENESAS is configured
Date: Wed, 26 Aug 2015 00:15:57 +0300
Message-ID: <55DCDB0D.8060201@cogentembedded.com>
References: <20150825080320.GA15681@vergenet.net>
 <55DC2899.2050205@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55DC2899.2050205@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/2015 11:34 AM, Sergei Shtylyov wrote:

>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> Currently the renesas ethernet driver directory is compiled if SH_ETH is
>> configured rather than NET_VENDOR_RENESAS. Although incorrect that was
>> quite harmless as until recently as SH_ETH configured the only driver in
>> the renesas directory. However, as of c156633f1353 ("Renesas Ethernet AVB
>> driver proper") the renesas directory includes another driver, configured
>> by RAVB, and it makes little sense for it to have a hidden dependency on
>> SH_ETH.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> [horms: rewrote changelog]
>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
>     Sorry about missing that when submitting the AVB driver.

    BTW, why against net-next? I consider this a fix.

MBR, Sergei

