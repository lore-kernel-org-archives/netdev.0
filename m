From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 9 May 2008 15:47:30 +0200
Message-ID: <f4845fc0805090647j64ec5555i46e4af3269db773d@mail.gmail.com>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com>
	 <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
	 <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
	 <200805092221.57251.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Jason Stubbs" <j.stubbs@linkthink.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:33001 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbYEINrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 09:47:37 -0400
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m49DlVG1005142
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 14:47:31 +0100
Received: from wf-out-1314.google.com (wff28.prod.google.com [10.142.6.28])
	by zps19.corp.google.com with ESMTP id m49DlUtj024495
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 06:47:30 -0700
Received: by wf-out-1314.google.com with SMTP id 28so1563303wff.21
        for <netdev@vger.kernel.org>; Fri, 09 May 2008 06:47:30 -0700 (PDT)
In-Reply-To: <200805092221.57251.j.stubbs@linkthink.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 9, 2008, Jason Stubbs wrote:
> I haven't applied the patch and done a diff to individual files to be certain, but I'm pretty sure that the patch is mainly just a directory change.

Yes, this is only a directory move of the current code in the kernel
(with the needed small Kconfig and Makefile adjustments for that, of
course).

Basically, you can arrive at this patch by doing:

$ git mv net/ipv4/ipvs net/netfilter
change net/ipv4/Kconfig:
        - source "net/ipv4/ipvs/Kconfig" => move (with adjusted dir)
to net/netfilter/Kconfig
change net/ipv4/Makefile:
        - obj-$(CONFIG_IP_VS) += ipvs/   => move to net/netfilter/Makefile

Julius

-- 
Google Switzerland GmbH
