From: Samuel Tardieu <sam@rfc1149.net>
Subject: Re: [PATCH 01/02] net/ipv6: seperate sit driver to extra module
Date: 06 Oct 2006 14:24:11 +0200
Message-ID: <87zmc9k4yc.fsf@willow.rfc1149.net>
References: <20061006093402.GA12460@zlug.org> <87d595lln3.fsf@willow.rfc1149.net> <20061006120917.GC12460@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:11731 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751238AbWJFMZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 08:25:53 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GVolU-0004Q7-Nl
	for netdev@vger.kernel.org; Fri, 06 Oct 2006 14:25:21 +0200
Received: from zaphod.rfc1149.net ([88.191.14.223])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2006 14:25:20 +0200
Received: from sam by zaphod.rfc1149.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2006 14:25:20 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Joerg" == Joerg Roedel <joro-lkml@zlug.org> writes:

Joerg> It is enabled per default because the users get this per
Joerg> default when using the current IPv6 module. James Morris
Joerg> mentioned this issue yesterday. I think setting the default to
Joerg> N would be more consistent, but the Y is probably less painfull
Joerg> for the users.

Makes sense. I proposed this because I reconfigure my kernel with
"make oldconfig" and see new questions pop up. Maybe menuconfig and
xconfig should proeminently highlight NEW questions from the top-level
(by using a bold font on any item which is either new or has new
sub-items) so that users get a clear view of what they may need to
configure.

  Sam
-- 
Samuel Tardieu -- sam@rfc1149.net -- http://www.rfc1149.net/

