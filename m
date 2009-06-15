From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 11:36:09 +0900
Message-ID: <20090615113609.db5c0613.usui@mxm.nes.nec.co.jp>
References: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <tgraf@infradead.org>, <netdev@vger.kernel.org>,
	<containers@lists.linux-foundation.org>
To: =?UTF-8?B?6rmA7J6s7Je0?= <gauri@etri.re.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:56861 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbZFOCur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 22:50:47 -0400
In-Reply-To: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Cheiyol

> # classid 1:10
> 
> echo 0x1000A > /dev/cpuctl/foo/net_cls.classid
> 
> #classid 1:20
> 
> echo 0x10014 > /dev/cpuctl/bob/net_cls.classid

(snip)

> # add class 1:10 for foo group
> 
> $TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit
> 
> # add class 1:20 for bob group
> 
> $TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit
> 
> # default class
> 
> $TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit

In class ID to use TC, both a major number and a minor number are hexadecimal.
So 1:10 equals 0x00010010.

I think, you should set 0x10010 to net_cls.classid if you classify to 1:10.
-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
