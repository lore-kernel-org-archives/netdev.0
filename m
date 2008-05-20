From: Scott Wood <scottwood@freescale.com>
Subject: Re: Oops in fs_enet driver with preempt-rt
Date: Tue, 20 May 2008 11:21:20 -0500
Message-ID: <4832FA80.7060807@freescale.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B046E728C@ismail.innsys.innovsys.com> <DCEAAC0833DD314AB0B58112AD99B93B046E72C3@ismail.innsys.innovsys.com> <4832F139.1020502@freescale.com> <DCEAAC0833DD314AB0B58112AD99B93B046E73C6@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Rune Torgersen <runet@innovsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:39852 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755955AbYETQUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 12:20:41 -0400
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93B046E73C6@ismail.innsys.innovsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rune Torgersen wrote:
> Hmm.... ttyCPM1 output seems to be kinda garbled... Any ideas?
> Incomplete locking between printk and userland use of ttyCPM1 as
> console?

s/incomplete/nonexistent/ :-P

Try acquiring port->lock in cpm_uart_console_write.

-Scott
