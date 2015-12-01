From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 1/6] net: thunderx: Force to load octeon-mdio before bgx driver.
Date: Tue, 1 Dec 2015 21:54:57 +0530
Message-ID: <CA+sq2Cfc2nu=6KEODHroaY_cDk4uuJ5XHs62b-UKHo68KWmppA@mail.gmail.com>
References: <1448961223-41888-2-git-send-email-sunil.kovvuri@gmail.com>
	<565D9E04.8010203@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565D9E04.8010203@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks a lot, will fix and repost the patch.

On Tue, Dec 1, 2015 at 6:47 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 12/1/2015 12:13 PM, Sunil Goutham wrote:
>
>> From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
>>
>> Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
>> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
>> ---
>>   drivers/net/ethernet/cavium/thunder/thunder_bgx.c |    3 +++
>>   drivers/net/ethernet/cavium/thunder/thunder_bgx.h |    1 +
>>   2 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>> b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>> index 180aa9f..1fb72dd 100644
>> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>> @@ -1009,6 +1009,9 @@ static int bgx_probe(struct pci_dev *pdev, const
>> struct pci_device_id *ent)
>>         struct bgx *bgx = NULL;
>>         u8 lmac;
>>
>> +       /*Load octeon mdio driver*/
>
>
>    Please insert spaces after /* and before */ (unless it's a common comment
> style in this driver).
>
> [...]
>
> MBR, Sergei
>
