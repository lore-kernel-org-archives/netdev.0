From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: discard dual emac default
 vlan configuration
Date: Thu, 22 Jan 2015 13:50:26 +0530
Message-ID: <54C0B2CA.1080001@ti.com>
References: <1421756740-32180-1-git-send-email-mugunthanvnm@ti.com> <54BE6573.1040801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <stable@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54BE6573.1040801@cogentembedded.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 January 2015 07:55 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 1/20/2015 3:25 PM, Mugunthan V N wrote:
> 
>> In Dual EMAC, the default vlans are used to segregate rx packets between
> 
>    VLANs. And RX.
> 
>> the ports, so adding the same default vlan to the switch will affect the
> 
>    VLAN.
> 
>> normal packet transfers. So returning error on addition of dual emac
> 
>    EMAC.
> 
>> default vlans.
> 
>    VLANs.
> 
>> Even if emac 0 default port vlan is added to emac 1, it will lead to
> 
>    EMAC. And VLAN
> 
>> break
> 
>    Breaking.
> 
>> dual EMAC port seperations.
> 
>    Separations.
> 
>> Fixes: d9ba8f9 (driver: net: ethernet: cpsw: dual emac interface
>> implementation)
> 
>    12 hex digits, please.
> 
>> Cc: <stable@vger.kernel.org> # v3.9+
>> Reported-by: Felipe Balbi <balbi@ti.com>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>>   drivers/net/ethernet/ti/cpsw.c | 22 ++++++++++++++++++++++
>>   1 file changed, 22 insertions(+)
> 
>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>> b/drivers/net/ethernet/ti/cpsw.c
>> index e068d48..7c32815 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -1683,6 +1683,19 @@ static int cpsw_ndo_vlan_rx_add_vid(struct
>> net_device *ndev,
>>       if (vid == priv->data.default_vlan)
>>           return 0;
>>
>> +    if (priv->data.dual_emac) {
>> +        /* In dual EMAC, reserved VLAN id should not be used of
> 
>    s/of/for/, perhaps?
> 
>> +         * creating vlan interfaces as this can break the dual
> 
>    s/vlan/VLAN/. Be consistent, please.
> 
>> +         * EMAC port seperation
> 
>    Separation.
> 
> [...]

Will fix this and resubmit next version.

Regards
Mugunthan V N
