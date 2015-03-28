From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] of_net: factor out repetitive code from of_get_mac_address()
Date: Sat, 28 Mar 2015 20:17:57 +0300
Message-ID: <5516E245.30605@cogentembedded.com>
References: <1776166.J84mUn2Yu8@wasted.cogentembedded.com> <20150328133445.52B51C40AAB@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Grant Likely <grant.likely@linaro.org>, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:36039 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbC1RSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 13:18:02 -0400
Received: by labe2 with SMTP id e2so91049207lab.3
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2015 10:18:00 -0700 (PDT)
In-Reply-To: <20150328133445.52B51C40AAB@trevor.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/28/2015 04:34 PM, Grant Likely wrote:

>> of_get_mac_address() basically does the same  thing thrice, every  time with  a
>> different  property  name,  so it makes sense to factor out the repetitive code
>> into separate function. While at it, we can start using ETH_ALEN instead of the
>> bare number and drop unnecessary parens around the property length check.

>> The resulting ARM object file is 100 bytes less in size than before the patch.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> The patch is against Grant Likely's 'linux.git' repo's 'devicetree/next' branch.

> Thanks for looking at this, I've merged it.

> Since you're already playing with this, could you also write a unittest
> of of_get_mac_addr()? (drivers/of/unittest.c & drivers/of/unittest-data)

    Unfortunately, I'm constantly low on time. Even this patch was done on 
weekend.

> g.

WBR, Sergei
