From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 driver causes kernel crash as of 2.6.18.1
Date: Wed, 1 Nov 2006 16:11:51 +0000
Message-ID: <6278d2220611010811r72424249h2a2184d7e466b32f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Linux Netdev" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946860AbWKAQLy@vger.kernel.org>
To: jclark@metricsystems.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Clark wrote:
> I have been compiling kernels from 2.6.16.16 on to see if there is any
> improvement
> in the Sky2 driver. The most recent official kernel version, 2.6.18.1,
> as of 10/31/06
> seems to still have problems.
>
> The crash debug splat indicates that the transmit routine was being
> executed when
> the final crash occured. But before the crash there were a series of
> diagnostics from
> the driver:
>
> NETDEV WATCHDOG: eth4: transmit time out
> sky2 eth4: tx timeout
> sky2 hardware hung? flushing
>
> messages.
>
> Is there any better driver in a 'unstable' kernel that someone has
> tested sufficiently?
>
> Thanks
> John Clark

I've been using sky2 v1.9 (in eg linux-2.6.19-rc3) on two sky2
platforms, running 100s of gigabytes via NFSv4 and CIFS without
problem. In earlier versions, I'd hit a race after a few GBs at high
load; Stephen Hemminger has done a great job.
-- 
Daniel J Blueman
