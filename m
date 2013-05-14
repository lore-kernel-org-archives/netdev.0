From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH 15/15] ptp: PTP_1588_CLOCK_PCH depends on x86
Date: Tue, 14 May 2013 16:20:09 +0200
Message-ID: <51924819.3060907@suse.cz>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz> <1367936303-13386-15-git-send-email-jslaby@suse.cz> <20130507192938.GA3599@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
	netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
	Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130507192938.GA3599@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2013 09:29 PM, Richard Cochran wrote:
> On Tue, May 07, 2013 at 04:18:23PM +0200, Jiri Slaby wrote:
>> From: Jeff Mahoney <jeffm@suse.com>
>>
>> The PCH EG20T is only compatible with Intel Atom processors so it
>> should depend on x86.
> 
> This patch has been submitted before,
> 
>    https://patchwork.kernel.org/patch/2069071/
> 
> and at that time the reaction was that it is good to have drivers
> cross-compiled, if only for code quality reasons.

Hmm, then it depends whether the kernel is for users or for developers.
I, as a user, do not really want to compile drivers with allmodconfig
which I have no way to load/use.

And allmodconfig is basically what we, users (SUSE distributors in this
case) do. So having this driver being built makes our life harder (in
the meaning we have to have specific rules about disabling unwanted
drivers from configs).

And, developers should have a testbed where they build 32bit configs.
And we actually have that for -next AFAIU.

thanks,
-- 
js
suse labs
