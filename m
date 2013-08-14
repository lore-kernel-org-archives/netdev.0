From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Query: Regarding 8211E Phy module support in drivers/net/phy
Date: Wed, 14 Aug 2013 16:07:40 +0200
Message-ID: <520B8F2C.5090308@st.com>
References: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: Sharma Bhupesh-B45370 <B45370@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:58141 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759740Ab3HNOIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 10:08:00 -0400
In-Reply-To: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2013 8:50 PM, Sharma Bhupesh-B45370 wrote:
> Hi Peppe,
>
> This regarding the patch prepared by you for adding RTL8211E support in
> drivers/net/phy/realtek.c
>
> commit ef3d90491a15f0d5cf1ec39a38a45dac6968fb2a
> Author: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date:   Wed Jan 23 00:30:03 2013 +0000
>
>      net: phy: realtek: add rtl8211e driver
>
>      This patch adds the minimal driver to manage the
>      Realtek RTL8211E 10/100/1000 Transceivers.
>
> I see a macro specific to 8211E:
> +#define        RTL8211E_INER_LINK_STAT 0x10
>
> I was having a look at the RTL8211E(G) datasheet and could see
> the following bit positions for INER register (Address 0x12):
>
> [7:1] as Reserved
> [0] as Jabber Interrupt
>
> If I am not wrong a value 0x10 written to the INER register tries to set bit [4] which seems
> Reserved.

Hello Sharma
you are right RTL8211E_INER_LINK_STAT should be 0x400
I will test it again (just to find the hw) and prepare/send a new patch.

Many thanks

peppe

>
> Or am I missing something here.
> Please let me know your views on the same.
>
> Thanks,
> Bhupesh
>
>
>
