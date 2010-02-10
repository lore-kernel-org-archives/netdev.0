From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 10 Feb 2010 15:50:14 +0100
Message-ID: <201002101550.14690.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com> <1265671815.6480.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Ed Swierk <eswierk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56416 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab0BJOuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:50:18 -0500
In-Reply-To: <1265671815.6480.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 February 2010, Ed Swierk wrote:
> I fixed this problem with the change below.  I'm not sure if replacing
> smp_processor_id() with get_cpu() is the right thing to do but it works
> for macvtap at least.

I think we also need to ensure the device doesn't go away, which
was one of the reasons for the rcu_read_lock_bh() earlier.

	Arnd
