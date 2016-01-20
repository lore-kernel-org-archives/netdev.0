From: Lucas Tanure <tanure@linux.com>
Subject: Re: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Wed, 20 Jan 2016 09:49:02 -0200
Message-ID: <CAJX_Q+2OZf05CsXRm7LOU0anO54MuTKEx0reR_mve8QEBqwiPg@mail.gmail.com>
References: <1453246074-1054-1-git-send-email-tanure@linux.com>
	<569F7308.9060008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <569F7308.9060008@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jan 20, 2016 at 9:44 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 1/20/2016 2:27 AM, Lucas Tanure wrote:
>
>> Use eth_zero_addr to assign the zero address to the given address array
>> instead of memset when second argument is address of zero.
>
>
>    What address? memset() takes just 1 address. :-)

I mean the vf->mac, a pointer to a six-byte array containing the
Ethernet address.

>
>> Signed-off-by: Lucas Tanure <tanure@linux.com>
>> ---
>>   drivers/net/ethernet/sfc/ef10_sriov.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c
>> b/drivers/net/ethernet/sfc/ef10_sriov.c
>> index 3c17f27..10f60db 100644
>> --- a/drivers/net/ethernet/sfc/ef10_sriov.c
>> +++ b/drivers/net/ethernet/sfc/ef10_sriov.c
>> @@ -527,7 +527,7 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int
>> vf_i, u8 *mac)
>>         return 0;
>>
>>   fail:
>> -       memset(vf->mac, 0, ETH_ALEN);
>> +       eth_zero_addr(vf->mac);
>>         return rc;
>>   }
>>
>
> MBR, Sergei
>

Thanks, Tanure
