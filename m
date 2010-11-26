From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the slaves mac address
Date: Thu, 25 Nov 2010 19:26:31 -0800
Message-ID: <8879.1290741991@death>
References: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com> <31169.1290641617@death> <AANLkTi=-DzUmopboX13V_cd=mZnmD=mBNNCuhQYF0PQQ@mail.gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Strand <dpstrand@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:50691 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346Ab0KZD0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Nov 2010 22:26:36 -0500
In-reply-to: <AANLkTi=-DzUmopboX13V_cd=mZnmD=mBNNCuhQYF0PQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Strand <dpstrand@gmail.com> wrote:

>We have a use case where we assign a mac to the bond device, because
>the slave device configuration may change periodically. With older
>kernels, it honored the assigned mac and everything was fine, with
>2.6.36 it now uses the mac of whatever slave device is first instead
>of our assigned one.
>
>ifenslave code and documentation appears to still support the old way,
>where a bond assigned mac will reign supreme, so this patch restores
>that behavior.

	Ok, fair enough.  If we want to get back to the original
behavior, however, your patch should only test for zero MAC address
instead of testing for zero MAC address in addition to first slave.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
