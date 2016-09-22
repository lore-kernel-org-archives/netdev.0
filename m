From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next v2 3/3] net: ethernet: mediatek: add the dts property to set if TRGMII supported on GMAC0
Date: Thu, 22 Sep 2016 23:21:44 +0800
Message-ID: <1474557704-19011-1-git-send-email-sean.wang@mediatek.com>
References: <b04e14ff-15db-9cc8-9490-204da8c5837d@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>
To: <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b04e14ff-15db-9cc8-9490-204da8c5837d@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Date: Thu, 22 Sep 2016 14:28:36 +0300, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>Hello.
>
>On 9/22/2016 5:33 AM, sean.wang@mediatek.com wrote:
>
>> From: Sean Wang <sean.wang@mediatek.com>
>>
>> Add the dts property for the capability if TRGMII supported on GAMC0
>>
>> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
>> ---
>>  Documentation/devicetree/bindings/net/mediatek-net.txt | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
>> index 6103e55..7111278 100644
>> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
>> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
>> @@ -31,7 +31,10 @@ Optional properties:
>>  Required properties:
>>  - compatible: Should be "mediatek,eth-mac"
>>  - reg: The number of the MAC
>> -- phy-handle: see ethernet.txt file in the same directory.
>> +- phy-handle: see ethernet.txt file in the same directory and
>> +	the phy-mode "trgmii" required being provided when reg
>
>   Since you've modified the generic parser of the "phy-mode" to add your 
>"trgmii", you also need to update ethernet.txt...
>

>> +	is equal to 0 and the MAC uses fixed-link to connect
>> +	with inernal switch such as MT7530.
>
>   Internal.
>

thank you for taking time and effort to review this
I will fix it up
