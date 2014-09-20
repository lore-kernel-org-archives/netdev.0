From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: action stats broken?
Date: Sat, 20 Sep 2014 09:17:09 -0400
Message-ID: <541D7E55.6070306@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: john Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33170 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbaITNRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 09:17:12 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so548277igd.10
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 06:17:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, dont have time to chase this today and it may be fixed in the
latest  tree. Possibly recent patches or likely earlier patches
even.

It seems stats are no longer displaying for actions.
This is a net-next kernel. I have tried kernel 3.16.0-rc2
and 3.17.0-rc4 with same results.

Simple test case:

----
root@moja-1:~# tc actions add  action drop index 4
root@moja-1:~# tc -s actions ls action gact

	action order 0: gact action drop
	 random type none pass val 0
	 index 4 ref 1 bind 0 installed 9 sec used 4 sec
-----

What I would have expected to see is:
---
	action order 0: gact action drop
	 random type none pass val 0
	 index 4 ref 1 bind 0 installed 9 sec used 4 sec
          Sent 108948 bytes 1297 pkts (dropped 1297, overlimits 0)
---


cheers,
jamal
