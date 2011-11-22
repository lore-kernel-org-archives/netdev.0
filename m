From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: drivers/net: Kconfig & Makefile cleanup
Date: Tue, 22 Nov 2011 08:14:38 -0800
Message-ID: <4ECBCA6E.20709@xenotime.net>
References: <1321944540.2839.220.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy5-pub.bluehost.com ([67.222.38.55]:51982 "HELO
	oproxy5-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757470Ab1KVQRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 11:17:04 -0500
In-Reply-To: <1321944540.2839.220.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2011 10:49 PM, Ben Hutchings wrote:
> You wrote that (some time ago now):
>> As a side cleanup, found that the arcnet, token ring, and PHY
>> Kconfig options were a tri-state option and should have been
>> a bool option.
> 
> How did you decide that?  This seems to be correct for TR, but ARCNET
> and PHYLIB each select some support code that can be built as a module
> (and which has been, in Debian).

For CONFIG_TR, it causes some build errors in snap & llc, but that is
due to a kconfig problem for which there is a test patch (not merged
anywhere).

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
