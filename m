From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/6] net: add the nwhwconfig support
Date: Thu, 17 Nov 2011 11:17:33 +0100
Message-ID: <4EC4DF3D.5040009@st.com>
References: <1321516900-616-1-git-send-email-peppe.cavallaro@st.com> <20111117.030625.229541498275597867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mamoroso@micron.com, shiraz.hashim@st.com,
	armando.visconti@st.com, stuart.menefy@st.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:60843 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755511Ab1KQKR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 05:17:58 -0500
In-Reply-To: <20111117.030625.229541498275597867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On 11/17/2011 9:06 AM, David Miller wrote:
> From: Giuseppe CAVALLARO<peppe.cavallaro@st.com>
> Date: Thu, 17 Nov 2011 09:01:40 +0100
>
>> Network drivers support hardware level configuration via utilities such as
>> ifconfig, ethtool and mii-tool. However sometimes these settings need to be
>> adjusted before a file system is available (typically if the root file system
>> uses NFS).
>
> No way, use an initial ramdisk.

Yes I agree with you that ramdisk is a solution :-) but this driver is 
actually helping many users of stmmac on several platforms.
Hmm, I also think it can be useful.

For example, in my environment, I need to continuously boot a Kernel on 
ST boxes and mount a rootFS via NFS to have the access to the full 
(arm/sh - glibc/uclibc) distributions (to use several packages for 
networking tests, X system etc).
This driver helps me to go faster in the normal development.
I am aware that starting with a ramdisk I could do that but with extra 
steps and configuration.
I mean, I want to pass all my network configuration in command line, 
such as ip= option, and this driver should not be in conflict with this 
logic.

With this small driver it's possible to force link speed and duplex 
modes when the kernel boots and this help me on validating HW and 
performing tests as well.

In any case, the driver is on the mailing list and other people can test 
it and provide feedback and enhancements.

Best Regards
Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
