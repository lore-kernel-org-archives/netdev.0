From: Daniel Drake <dsd@gentoo.org>
Subject: e1000e hardware CRC stripping breaks bridging
Date: Tue, 12 Feb 2008 13:27:58 +0000
Message-ID: <47B19EDE.5020802@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from probity.mcc.ac.uk ([130.88.200.94]:55388 "EHLO
	probity.mcc.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758536AbYBLNyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 08:54:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Johan Andersson reported on the Gentoo bugzilla that the hardware CRC 
stripping enabled by e1000e breaks bridging because sometimes the CRC is 
not stripped:
https://bugs.gentoo.org/show_bug.cgi?id=209235

Apparently "upstream" are aware but I couldn't find any mails or bug 
reports on this topic.

What's the current status of this issue? Perhaps we should disable 
hardware CRC stripping for 2.6.24.x/2.6.25 until this gets fixed?

Thanks,
Daniel
