From: Vlad Lungu <vlad.lungu@windriver.com>
Subject: Re: [PATCH] stmmac: fix stmmac_resume removing not yet used shutdown
 flag
Date: Mon, 29 Nov 2010 12:32:53 +0200
Message-ID: <4CF38155.3010601@windriver.com>
References: <1290740072-1341-1-git-send-email-peppe.cavallaro@st.com> <4CEFC14B.70806@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37596 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab0K2Kcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 05:32:54 -0500
In-Reply-To: <4CEFC14B.70806@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peppe CAVALLARO wrote:
> On 11/26/2010 3:11 PM, Peppe CAVALLARO wrote:
>> The commit to convert to use the dev_pm_ops struct
>> introduces a bug. The shutdown flag is not yet used
>> because the hibernation on memory is done by using
>> the freeze callback.
>> Thanks to Vlad for having reported it.
> Hi Vlad,
> as we discussed via email, I'll also look at how to manage the
> patch that reworked the private structure and that's generating
> problems on your HW (I'll also try to have it for testing!).
> 

Actually, this is is not a blocking problem. I can kmalloc a platform
info structure and fill it with the relevant data on probe. It just feels ... wrong.

The way I see it, the platform info is similar to the PNP on an ISA bus or
the PCI header of a device. Having platform info for a PCI device is kind of
a hack. You didn't know that there's a PCI device out there and that someone
wants to submit a patch for it, so it probably made sense at the time to rework
the structure that particular way.

Regards,
Vlad



