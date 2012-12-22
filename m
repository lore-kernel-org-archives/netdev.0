From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Regression in 3.8-rc1:  "BUG: sleeping function called from invalid
 context"
Date: Sat, 22 Dec 2012 13:04:29 -0600
Message-ID: <50D6043D.9010600@lwfinger.net>
References: <50D5E9D9.3070904@lwfinger.net> <20121222180247.GA10250@liondog.tnic> <1356199828.21834.8500.camel@edumazet-glaptop> <20121222183044.GA10263@liondog.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:53889 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923Ab2LVTEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 14:04:33 -0500
In-Reply-To: <20121222183044.GA10263@liondog.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2012 12:30 PM, Borislav Petkov wrote:
> On Sat, Dec 22, 2012 at 10:10:28AM -0800, Eric Dumazet wrote:
>> RTNL is a mutex, its perfectly valid to use GFP_KERNEL while holding a
>> mutex.
>
> Right, sorry. The check fires because we have preemption disabled.
>
>> As replied before your mail, fix for the problem is already in David
>> tree.
>
> Yep, saw that after hitting send.

Eric and Borislav,

The patch does fix my problem. I expect that it will be in mainline by -rc2.

Thanks,

Larry
