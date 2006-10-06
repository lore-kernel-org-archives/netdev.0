From: Samuel Tardieu <sam@rfc1149.net>
Subject: Re: [PATCH 01/02] net/ipv6: seperate sit driver to extra module
Date: 06 Oct 2006 13:38:24 +0200
Message-ID: <87d595lln3.fsf@willow.rfc1149.net>
References: <20061006093402.GA12460@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:26011 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751222AbWJFLmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 07:42:03 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GVo4d-0001iX-Kr
	for netdev@vger.kernel.org; Fri, 06 Oct 2006 13:41:04 +0200
Received: from zaphod.rfc1149.net ([88.191.14.223])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2006 13:41:03 +0200
Received: from sam by zaphod.rfc1149.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2006 13:41:03 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Joerg" == Joerg Roedel <joro-lkml@zlug.org> writes:

Joerg> this is the submit of the patch discussed yesterday to compile
Joerg> the sit driver as a seperate module.

Your patch looks ok to me, but given that many people won't need sit,
why is it enabled by default? Omitting it would save 10k of kernel
text on x86 and people will see the new kernel configuration option
anyway and will enable it if needed.

  Sam
-- 
Samuel Tardieu -- sam@rfc1149.net -- http://www.rfc1149.net/

