From: Jared <nitro@legroom.net>
Subject: Re: [REGRESSION, PATCH] sky2 WOL fix
Date: Fri, 17 Feb 2012 14:13:05 -0600
Message-ID: <4F3EB4D1.8090002@legroom.net>
References: <4F3A1A5E.9090803@t-online.de>	<20120215091622.429fe9c3@nehalam.linuxnetplumber.net>	<4F3E9AC1.6060704@t-online.de> <20120217110147.1c00b31d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Knut Petersen <Knut_Petersen@t-online.de>, netdev@vger.kernel.org,
	dilieto@lineone.net, Mirko Lindner <mlindner@syskonnect.de>,
	Ralph Roesler <rroesler@syskonnect.de>, arekm@maven.pl,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.182.149.164.static.propagation.net ([64.182.149.164]:51508
	"EHLO legroom.c1pher.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751671Ab2BQUW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:22:29 -0500
In-Reply-To: <20120217110147.1c00b31d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2012 01:01 PM, Stephen Hemminger wrote:
> On Fri, 17 Feb 2012 19:21:53 +0100
> Knut Petersen <Knut_Petersen@t-online.de> wrote:
> 
>> Your commit broke existing support for WOL on a number of boards.
>> This is known to you and to bugzilla.kernel org since 2010.  A number of
>> people complained about that, but nothing happened.
>>
>> Neither your original commit description nor the description of the
>> PXE_LegNat_Sel I found at other places indicate that setting
>> PXE_LegNat_Sel could do any harm.
> 
> 
> Please lose the attitude. Any support of sky2 is done as a minor side
> project by me. People find a problem, I put in one fix, then someone else
> complains and another fix goes in. The regressions happen a lot in power management
> because the hardware is not well documented in this area and it is a complex
> interaction of kernel, BIOS, motherboard, and general shittiness of implementations.
> Because of that I am more likely to believe that what the Marvell code does
> is more based on experience on other platforms. The out-of-tree Marvell
> driver contains bits that are part of the Windows driver.

Attitudes aside, the general problem here is that someone (which I
believe is you, Stephen, based solely on the commit) committed a patch
two years ago which broke WoL support for a number of users.  I have no
doubt that you had some reason for making these changes, but a bug was
filed about this in 10/02/2010, followed by identification and
confirmation of both the problem and a solution 1 week later, and
absolutely nothing has been done since then.  Here's the bug:

https://bugzilla.kernel.org/show_bug.cgi?id=19492

I think we all understand that you volunteer your time for this, and I'm
most appreciative of your (and all kernel developer's) efforts, but
that's a long time for a known and easily fixable regression to be
ignored, without even a single comment on the issue since the fix was
identified.  And I will admit that I'm also pretty frustrated by the
need to re-patch the kernel on my server every single time I update it
to fix an obvious and known regression that, prior 2.6.34, worked
perfectly fine.

To Knut's points, my own motherboard (from Asus) is no longer supported
by the vendor either at this point, so a fix from that side is not
likely.  Is there any particular reason, any known side effects, why
this newer patch from Knut cannot be applied?  As thing's stand now,
there is already a definite problem, so unless there's a risk of
creating a larger, more widespread problem I think it'd make sense to
apply the patch and fix the current issue.

Clearly I'm no developer, but as a user that's been affected by this
problem for over a year and a half now I thought it worth chiming in.  I
hope some resolution can be reached on this.

Thanks.

-- 
Jared
