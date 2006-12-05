From: Andrew Victor <andrew@sanpeople.com>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 2
Date: 05 Dec 2006 08:15:58 +0200
Message-ID: <1165299358.12510.6.camel@fuzzie.sanpeople.com>
References: <1165236128.4606.104.camel@fuzzie.sanpeople.com>
	 <20061204100124.619de892@freekitty>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3285 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936198AbWLEGZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 01:25:46 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061204100124.619de892@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi Stephen,

> poll_controller is always called with interrupts already disabled.

All the other network drivers I looked at seem to disable the interrupt.


> The third argument to interrupt routines was dropped (struct pt_regs) in 2.6.19.
> Maybe that never got fixed in ARM?

My mistake - ARM was fixed up.
I rarely compile with netconsole support so this change slipped through.


Regards,
  Andrew Victor


