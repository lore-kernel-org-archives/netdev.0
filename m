From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: fix the noflags test in
 addrconf_get_prefix_route
Date: Thu, 10 Jan 2013 14:39:32 -0800 (PST)
Message-ID: <20130110.143932.748033133604759561.davem@davemloft.net>
References: <470C14E4-2866-4C55-89A3-D6751E1587C4@ipflavors.com>
	<50EE9141.6020805@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: r.kuntz@ipflavors.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andi@collax.com
To: yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50EE9141.6020805@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 10 Jan 2013 19:00:33 +0900

> Romain KUNTZ wrote:
>> From e7ece201c35615c44a3cfdc10ee28ad5a5878f41 Mon Sep 17 00:00:00 2001
>> From: Romain Kuntz <r.kuntz@ipflavors.com>
>> Date: Wed, 9 Jan 2013 15:02:26 +0100
>> Subject: [PATCH 1/1] ipv6: fix the noflags test in addrconf_get_prefix_route
>> 
>> The tests on the flags in addrconf_get_prefix_route() does no make
>> much sense: the 'noflags' parameter contains the set of flags that
>> must not match with the route flags, so the test must be done
>> against 'noflags', and not against 'flags'.
>> 
>> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
 ...
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
