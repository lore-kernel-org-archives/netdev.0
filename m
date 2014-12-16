From: Murali Karicheri <m-karicheri2@ti.com>
Subject: How to fix CHECK warning: testing a 'safe expression'
Date: Tue, 16 Dec 2014 13:23:00 -0500
Message-ID: <54907884.2040502@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:42318 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbaLPSW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 13:22:59 -0500
Received: from dflxv15.itg.ti.com ([128.247.5.124])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id sBGIMwdY030002
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:22:58 -0600
Received: from DLEE71.ent.ti.com (dlee71.ent.ti.com [157.170.170.114])
	by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id sBGIMwQi020567
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:22:58 -0600
Received: from [158.218.104.233] (ileax41-snat.itg.ti.com [10.172.224.153])	by
 dflp33.itg.ti.com (8.14.3/8.13.8) with ESMTP id sBGIMvsv008519	for
 <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:22:58 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev maintainers,

I got a comment to address CHECK warning and wondering how to address 
'warning: testing a 'safe expression' which appears when using
IS_ERR_OR_NULL(foo)

where foo is defined as

struct foo_type *foo;

The foo get assigned only NULL or ERR_PTR(error code). So I believe the 
usage is correct. But then how do I make the CHECK happy of its usage?

I have tried doing a grep on the current usage of IS_ERR_OR_NULL() and 
found 276 of them causes this warning in the v3.18 version of the kernel 
that I am using

$ grep -r "warning: testing a 'safe expression" * | wc -l
276

1) Can someone explain what this warning means?

2) Is it acceptable to post patches to netdev list with this warning?

3) if not, how this is expected to be fixed? Any example usage to fix 
this warning will be helpful.

Thanks in advance for
-- 
Murali Karicheri
Linux Kernel, Texas Instruments
