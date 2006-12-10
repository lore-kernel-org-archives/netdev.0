From: Paul Collins <paul@briny.ondioline.org>
Subject: Re: Please make CONFIG_CFG80211 harder to enable
Date: Sun, 10 Dec 2006 19:48:39 +1300
Message-ID: <87hcw49rg8.fsf@briny.internal.ondioline.org>
References: <1165654123.2816.29.camel@portland.localdomain>
	<20061209160640.GA3365@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:1230 "EHLO
	jenny.ondioline.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760121AbWLJGyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 01:54:09 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061209160640.GA3365@tuxdriver.com> (John W. Linville's message
	of "Sat\, 9 Dec 2006 11\:06\:46 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"John W. Linville" <linville@tuxdriver.com> writes:

> On Sat, Dec 09, 2006 at 03:48:43AM -0500, Pavel Roskin wrote:
>> Hello!
>> 
>> Somebody please mark CONFIG_CFG80211 in wireless-dev.git as
>> experimental/broken/incomplete/whatever.  Not only doesn't it work, but
>> it also breaks Wireless Extensions if enabled, even if CONFIG_D80211 is
>> disabled.
>> 
>> Driver developers should know that if they enable CONFIG_CFG80211 they
>> won't be able to debug their drivers effectifely; they'll have to fix
>> cfg80211 first.
>
> Perhaps you could be more specific?  I'm sending this to you from a
> box booted on the current (~1 week old) wireless-dev kernel using a
> WEXT-configured ipw2200 device.
>
> What problems are you experiencing?  CFG80211 shouldn't interfere w/
> WEXT if a driver doesn't support it.

I think I hit this too when I started playing with wireless-dev a week
or so ago.  I had CFG80211 enabled and iwconfig reported "wireless
extensions not supported" with orinoco, bcm43xx and bcm43xx-d80211.

-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood
