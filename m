From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: https://patchwork.ozlabs.org/patch/579654?
Date: Tue, 16 Feb 2016 23:43:39 +0100
Message-ID: <56C3A61B.2040004@stressinduktion.org>
References: <87bn7gv2mn.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bn7gv2mn.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.02.2016 21:09, Rainer Weikusat wrote:
> https://patchwork.ozlabs.org/patch/579654
>
> lists this as 'superseded', among with the older versions of the patch
> which changed the error handling. But at least, I couldn't find anything
> superseding it. This was supposed to address the different-but-related
> problem demonstrated by the following (slightly modified) test program:
>
> ---------
 > [...]
> --------
>
> Because the receiver has to wait for the message, it will hit the
> continue in unix_stream_read_generic. This causes the size-check of the
> do-while loop to be executed which terminates the loop as the size is
> zero without copying the credential information.
>
> Just wondering if this might have been lost in the noise ...

I think the patch got lost, probably just resending is the easiest 
solution. ;)

For the patch:
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
