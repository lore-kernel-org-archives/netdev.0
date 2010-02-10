From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 10 Feb 2010 15:52:03 +0100
Message-ID: <201002101552.03722.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com> <1265685901.639.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Ed Swierk <eswierk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:51351 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab0BJOwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:52:10 -0500
In-Reply-To: <1265685901.639.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 February 2010, Ed Swierk wrote:
> I've encountered some more problems, with various users of
> macvtap_file_get_queue() either calling or neglecting to call
> macvtap_file_put_queue() in error cases.
> 
> I modified your patch so that when macvtap_file_get_queue() returns 0,
> it also calls rcu_read_unlock_bh(), and modified the users
> appropriately.
> 
> This patch also incorporates my preemption fix for macvlan_count_rx().
> 
> Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>

Good idea, I'll incorporate it into my next fix, need to think
about it some more to make sure I catch all the corner cases
of the lifetime rules.

Thanks,

	Arnd
