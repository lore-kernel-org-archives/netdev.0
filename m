From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2] brcmfmac: Make skb header writable before use
Date: Mon, 24 Apr 2017 20:59:02 +0200
Message-ID: <254f7f48-e592-e30a-06db-605a37750e42@broadcom.com>
References: <20170424130322.476-1-james.hughes@raspberrypi.org>
 <1493057382.6453.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493057382.6453.39.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 24-4-2017 20:09, Eric Dumazet wrote:
> On Mon, 2017-04-24 at 14:03 +0100, James Hughes wrote:
>> The driver was making changes to the skb_header without
>> ensuring it was writable (i.e. uncloned).
>> This patch also removes some boiler plate header size
>> checking/adjustment code as that is also handled by the
>> skb_cow_header function used to make header writable.
>>
>> This patch depends on
>> brcmfmac: Ensure pointer correctly set if skb data location changes
>>
>> Signed-off-by: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
>> ---
>> Changes in v2
>>   Makes the _cow_ call at the entry point of the skb in to the
>>   stack, means only needs to be done once, and error handling
>>   is easier.
>>   Split a separate minor bug fix off to a separate patch (which
>>   this patch depends on)
> 
> Best way to handle dependencies is to send a patch series.
> 
> 1/2 brcmfmac: Ensure pointer correctly set if skb data location changes
> 2/2 brcmfmac: Make skb header writable before use

There is actually no real dependency. Both are valid fixes of course but
either one applies to wireless-drivers-next/master on its own.

Regards,
Arend
