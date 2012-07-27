From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] iproute: Add route showdump command
Date: Fri, 27 Jul 2012 08:14:42 +0400
Message-ID: <501215B2.9010802@parallels.com>
References: <50110593.1070502@parallels.com> <20120726090315.4a566a46@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Smith <danms@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25785 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab2G0EOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 00:14:50 -0400
In-Reply-To: <20120726090315.4a566a46@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2012 08:03 PM, Stephen Hemminger wrote:
> On Thu, 26 Jul 2012 12:53:39 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> Some time ago the save+restore commands were added to ip route (git
>> id f4ff11e3, Add ip route save/restore). These two save the raw rtnl
>> stream into a file and restore one (reading it from stdin).
>>
>> The problem is that there's no way to get the contents of the dump
>> file in a human readable form. How about adding a command that reads
>> the rtnl stream from stdin and prints the data in a way the usual
>> "ip route list" does?
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> Being able to decode a dump is great idea.
> Are the user's smart enough not to try it out at the command prompt
> and get totally lost? Maybe another isatty() check is needed.
> 
> Another solution would be to put a small header on the save file with
> a magic number that could be checked. This would mean changing save/restore/showdump
> and ideally updating the magic file in distributions.
> .

Hm... The idea with magic looks reasonable.
I will look at what can be done here, thanks!
