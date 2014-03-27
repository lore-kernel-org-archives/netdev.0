From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: [PATCH 0/3] Fix stmmac-socfpga allmodconfig breakage in arm-soc
Date: Wed, 26 Mar 2014 19:05:13 -0500
Message-ID: <53336B39.3080209@gmail.com>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com> <201403262254.41069.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
	srinivas.kandagatla@st.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, arm@kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:57286 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbaC0AFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 20:05:16 -0400
In-Reply-To: <201403262254.41069.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/26/2014 04:54 PM, Arnd Bergmann wrote:
> On Wednesday 26 March 2014, dinguyen@altera.com wrote:
>> From: Dinh Nguyen <dinguyen@altera.com>
>>
>> Hi,
>>
>> These 3 patches are based on Arnd's patch to fix the allmodconfig for the
>> dwmac-socfpga implementation. I just broke the patch out into drivers,
>> dts, and dts documentation.
>>
>> The original patch is here:
>> http://lists.infradead.org/pipermail/linux-arm-kernel/2014-March/241518.html
>>
>> Arnd mentioned that he was thinking about just removing the dwmac-socfpga
>> and send out the new verion to the netdev tree, but I haven't seen it. So
>> just in case this solution might work, here are the patches.
>>
>> These patches are based on arm-soc/for-next.
>
> Hi Dinh,
>
> Thanks for putting these patches together. The problem I see with these
> is that we have multiple conflicts between my changes and the other
> patches that went into the netdev tree.
>
> Originally, the idea was that David Miller gave his Ack to have
> the patches merged through arm-soc, but I think that was a mistake,
> and they should have been treated like the other patches for
> the same driver, i.e. put the driver and binding changes into
> netdev, and the dt changes into arm-soc.
>
> If I apply your patches on top of the next/drivers branch, we get
> conflicts for a handful of files, and get Linus to resolve them.
> I tried applying my patch on Sunday, but backed it out because
> of this.
>
> My preferred solution at this point would be to revert the driver
> addition in the arm-soc tree and have David put the new version
> in, but I don't know if he still takes patches like that for 3.15.
>

That's fine. Do you mind if I send out a fresh patch based on the netdev 
tree? If there is still for 3.15, otherwise, going for 3.16 is fine.

Dinh
> 	Arnd
>
