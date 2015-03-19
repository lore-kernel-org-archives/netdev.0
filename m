From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: Re: [PATCH] mac802154: fix typo in header guard
Date: Thu, 19 Mar 2015 21:59:47 +0800
Message-ID: <550AD653.4050306@m4x.org>
References: <1426771420-29979-1-git-send-email-nicolas.iooss_linux@m4x.org>	 <20150319133724.GA14436@omega> <1426772786.23529.4.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, marcel@holtmann.org
To: Paul Bolle <pebolle@tiscali.nl>,
	Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33334 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbbCSN7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 09:59:51 -0400
In-Reply-To: <1426772786.23529.4.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 09:46 PM, Paul Bolle wrote:
> On Thu, 2015-03-19 at 14:37 +0100, Alexander Aring wrote:
>> On Thu, Mar 19, 2015 at 09:23:40PM +0800, Nicolas Iooss wrote:
>>> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
>>> Fixes: b6eea9ca354a ("mac802154: introduce driver-ops header")
>>
>> Acked-by: Alexander Aring <alex.aring@gmail.com>
>>
>> can you please queue this into bluetooth-next or even bluetooth?
> 
> Is the Fixes: tag needed?
> 
> mac802154.ko builds fine on my machine. There's also no error or warning
> included in the commit explanation. So it seems this is just a typo fix,
> not something that should be sent to stable too. Or did I miss something
> non-obvious?

No, you didn't miss anything.  It is only a fix for a typo I found while
testing LLVMLinux (clang warns about such typos with -Wheader-guard).

I added a Fixes: tag because it is easier to remove it afterwards that
to search for a commit when adding it.  I think this patch should not be
sent to stable@, and feel free to remove the tag if for you it means
"forward to stable@" (Documentation/SubmittingPatches is not clear about
whether a Fixes tag should be only used for real bugs or if it also
applies to compiler warnings).

Thanks for your quick replies.

Nicolas
