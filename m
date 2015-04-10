From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] configure: add missing INCLUDE to netnsid detection
Date: Fri, 10 Apr 2015 18:17:20 +0200
Message-ID: <5527F790.4080301@6wind.com>
References: <42d42073b18a4cc0aebbc912fcc14788693c0c75.1428522001.git.jbenc@redhat.com> <20150408194006.GA17685@angus-think.lan>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vadim Kochan <vadim4j@gmail.com>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36824 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075AbbDJQRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 12:17:23 -0400
Received: by wgsk9 with SMTP id k9so22586712wgs.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 09:17:22 -0700 (PDT)
In-Reply-To: <20150408194006.GA17685@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/04/2015 21:40, Vadim Kochan a =E9crit :
> On Wed, Apr 08, 2015 at 09:42:00PM +0200, Jiri Benc wrote:
>> Fixes: d116ff34145b0 ("ip netns: Fix rtnl error while print netns li=
st")
>> Signed-off-by: Jiri Benc <jbenc@redhat.com>
>> ---
>> The whole check added by d116ff34145b0 is dubious, though. This shou=
ld be
>> a run time check, not a compile time one.
[snip]
>
> On 3.18 I get same RTNL error with this fix, I agree that runtime che=
cking
> would be better than compile time checking, but how to do it, suppres=
s
> RTNL errors ?
I also hit this issue.
This whole check is done only to bypass some fprintf(stderr) messages f=
rom
rtnl_talk().
I think adding a mechanism like iplink_have_newlink() should be enough.

If nobody wants to do it, I will look at this on Monday.

Regards,
Nicolas
