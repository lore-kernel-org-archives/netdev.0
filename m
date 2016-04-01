From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: Reboot Failed was occurred after v4.4-rc1 during IPv6 Ready Logo
 Conformance Test
Date: Fri, 1 Apr 2016 11:40:01 +0900
Message-ID: <56FDDF81.9000402@jp.fujitsu.com>
References: <56FCCD18.9050306@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:32470 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbcDACkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 22:40:08 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id A21E6AC030C
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 11:40:01 +0900 (JST)
Received: from omame (omame.fct.css.fujitsu.com [10.24.14.171])
	by m3051.s.css.fujitsu.com (Postfix) with ESMTP id 8FCD4167
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 11:40:01 +0900 (JST)
Received: from [10.24.19.86] (ubi86.utsfd.cs.fujitsu.co.jp [10.24.19.86])
	by omame (Postfix) with ESMTPSA id 7B6F51E0088
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 11:40:01 +0900 (JST)
In-Reply-To: <56FCCD18.9050306@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2016年03月31日 16:09, Yuki Machida wrote:
> Hi all,
> 
> Reboot Failed was occurred at Linux Kernel after v4.4-rc1 during IPv6 Ready Logo Conformance Test.
> Not Fix a bug in v4.5-rc7 yet.
> I will conform that it fix a bug in v4.6-rc1.
I conform that it was not occurred in v4.6-rc1.

I will find a patch for this bug, and conform it was applied -stable kernel.
If it was not applied -stable kernel, I will report again.

> Currently, it is under investigation.
> 
> IPv6 Ready Logo
> https://www.ipv6ready.org/
> TAHI Project
> http://www.tahi.org/
> 
> I ran the IPv6 Ready Logo Core Conformance Test on Intel D510MO (Atom D510).
> It is using userland build with yocto project.
> 
> Test Environment
> Test Specification          : 4.0.6
> Tool Version                : REL_3_3_2
> Test Program Version        : V6LC_5_0_0
> Target Device               : Intel D510MO (Atom D510)
> 
> I conform that random testcases are failed.
> (e.g. No.5, No.130, No.131, No.134, No.167 and No.168)
> 
> Regards,
> Yuki Machida
> 
