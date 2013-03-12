From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 06/13] bnx2x: Control number of vfs dynamically
Date: Tue, 12 Mar 2013 07:50:02 -0400 (EDT)
Message-ID: <20130312.075002.1183319263027770351.davem@redhat.com>
References: <1363015073-25743-7-git-send-email-yuvalmin@broadcom.com>
	<20130312.052811.2289109881056913990.davem@davemloft.net>
	<6AE768456CEC4B4A9B2248CB6B87EB3E1BD10E88@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab3CLLtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 07:49:52 -0400
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BD10E88@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Tue, 12 Mar 2013 10:51:13 +0000

> Yuval Mintz from Broadcom started the
> "New commands to configure IOV features" thread
> http://marc.info/?l=linux-netdev&m=133638974914452&w=2
> As the discussion developed it was realized that virtual functions
> have a wider scope than networking.
> The discussion culminated with a submission to the pci tree:
> commit 1789382a72a537447d65ea4131d8bcc1ad85ce7b
> Author: Donald Dutile <ddutile@redhat.com>
> Date:   Mon Nov 5 15:20:36 2012 -0500
> 
> Adding sriov_numvfs and sriov_totalvfs to all SR-IOV capable pci devices.
> I would like to add that sysfs is actually a very convenient place to have 
> these knobs, because the virtfn entries there are a simple reliable way to
> know which vf devices sprouted from which PF devices and what are their
> names, which is very handy when scripting with VFs.

Oh that's right, thanks for reminding me about that discussion.
I rescing my objection.
