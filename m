From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 2/9] stmmac: add IEEE 1588-2002 PTP support
Date: Mon, 11 Mar 2013 07:35:36 +0100
Message-ID: <513D7B38.1070404@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com> <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com> <20130308063437.GB2382@netboy.at.omicron.at> <51398CFD.9010605@st.com> <20130310122553.GA6407@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	Rayagond K <rayagond@vayavyalabs.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-eu.st.com ([164.129.1.35]:61191 "EHLO
	beta.dmz-eu.st.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab3CKJU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 05:20:26 -0400
In-Reply-To: <20130310122553.GA6407@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/2013 1:25 PM, Richard Cochran wrote:
> On Fri, Mar 08, 2013 at 08:02:21AM +0100, Giuseppe CAVALLARO wrote:
>> On 3/8/2013 7:34 AM, Richard Cochran wrote:
>
>>>> +
>>>> +static int enh_desc_get_rx_timestamp_status(struct dma_desc *p)
>>>> +{
>>>> +	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
>>>
>>> Why not fix these FIXMEs for the next respin?
>>
>> This is fixed in the patch #5 where we use the extended descriptors
>> for PTP2.
>
> If possible, it is nice for the reviewers and for the logic of the
> patch series to order the changes so that these FIXMEs go away.
>
>>>> +	struct hwtstamp_config config;
>>>> +	struct timespec now;
>>>> +	u64 temp = 0;
>>>
>>> You add this new code here, but you change it all around again a few
>>> patches later. Please just submit the final, combined version.
>>
>> we kept these separately because the patch #5 (for example) depends on
>> another one that adds the extended descriptor support. Also If I add
>> all the code in a single patch this will be very big. I had some
>> problems to review all separately. So I suspect that if we merge all
>> in a single patch this will not help (especially myself). At any rate,
>> tell me if you prefer to have a single patch. I can do that.
>
> I am not asking for bigger patches. It is good to arrange your patches
> in small steps, since that makes both reviewing and bisecting easier.

I tried to do that :-(

>
> However, for brand new code, I find it quite annoying to read one
> patch, and then to have it all re-written in the next one. (If a new
> function *only* grows during a patch series, that is easy to follow.)
>
> So what I would like to see is a logical, understandable series of
> small steps, but when new code appears, it is the real, final form.

Ok, I'll try to better re-organize the patches in the next version.

Thx a lot
Peppe

>
> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
