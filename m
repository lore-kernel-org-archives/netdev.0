From: Roland Dreier <roland@purestorage.com>
Subject: Re: [Bug 41212] New: [regression] [3.1-git] ipoib causes kernel panic
 (NULL pointer dereference)
Date: Thu, 18 Aug 2011 08:50:06 -0700
Message-ID: <CAL1RGDW+iv0Apm=P6M26=U387dxpmZjoB3a8QgnqC1RMiJ7OiA@mail.gmail.com>
References: <bug-41212-11804@https.bugzilla.kernel.org/> <CAAk-MO8EToGY4OhmX1xPN01iAXR9WSsJXWxHG9EVyrSGYP3h5w@mail.gmail.com>
 <4E4A47BE.9090903@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Erez Shitrit <erezsh@dev.mellanox.co.il>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:42683 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755409Ab1HRPu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 11:50:28 -0400
In-Reply-To: <4E4A47BE.9090903@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remember that kernels after the release of 3.0 but before 3.1-rc1 will
report their version as 3.0 (even though they may have lots of commits
that went in after the 3.0 release).  Could that be the explanation?

On Tue, Aug 16, 2011 at 3:34 AM, Bernd Schubert
<bernd.schubert@fastmail.fm> wrote:
> Hello Erez,
>
> are you sure? Commit 69cce1d1404968f78b177a0314f5822d5afdbbfb is not in 3.0
> yet and I also don't see how 3.0 should fail there, as it tests immediately
> for "if (likely(skb_dst(skb)"
>
>
> Thanks,
> Bernd
>
> On 08/16/2011 10:06 AM, Erez Shitrit wrote:
>>
>> Hi,
>> it happened in 3.0 also, if you take the git tag v3.0-rc7 and below it
>> will work.
>>
>> Thanks, Erez
