From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 3/4] stmmac: verify the dma_cfg platform fields
Date: Thu, 19 Apr 2012 08:29:55 +0200
Message-ID: <4F8FB0E3.4000300@st.com>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com> <1334814502-29707-3-git-send-email-peppe.cavallaro@st.com> <4F8FAB12.2060108@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	spear-devel <spear-devel@list.st.com>
To: Viresh KUMAR <viresh.kumar@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:58498 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752036Ab2DSGb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 02:31:28 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0BA23230
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 06:31:21 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6BB461A01
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 06:31:21 +0000 (GMT)
In-Reply-To: <4F8FAB12.2060108@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/2012 8:05 AM, Viresh KUMAR wrote:
> On 4/19/2012 11:18 AM, Giuseppe CAVALLARO wrote:
>> Recently the dma parameters that can be passed from the platform
>> have been moved from the plat_stmmacenet_data to the stmmac_dma_cfg.
>>
>> In case of this new structure is not well allocated the driver can
>> fails. This is an example how this field is managed in ST platforms
>>
>> static struct stmmac_dma_cfg gmac_dma_setting = {
>>         .pbl = 32,
>> };
>>
>> static struct plat_stmmacenet_data stih415_ethernet_platform_data[] = {
>> 	{
>> 		.dma_cfg = &gmac_dma_setting,
>> 		.has_gmac = 1,
>> [snip]
>>
>> This patch so verifies that the dma_cfg passed from the platform.
>> In case of it is NULL there is no reason that the driver has to fail
>> and some default values can be passed. These are ok for all the
>> Synopsys chips and could impact on performances, only.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> cc: Viresh Kumar <viresh.kumar@st.com>
> 
> I really can't review it, as i am not stmmac expert. But, i am sure
> the problem i highlighted will be resolved by this patch.
> 
> Another thing, as SPEAr is using stmmac, can you always cc spear-devel@list.st.com
> for all stmmac patches.

Yes! I have forgotten to add spear guys ;-)

Thanks for your feedbak

Peppe

> 
