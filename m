From: Andreas Henriksson <andreas@fatal.se>
Subject: Problem using iptables MARK from tc.
Date: Tue, 06 Jan 2009 14:24:36 +0100
Message-ID: <1231248276.11025.148.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:56240 "EHLO
	amd64.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588AbZAFOMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 09:12:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Patrick and co.

I was hoping you might have some time to help out with a problem in tc
related to iptables modules. A bit of historical knowledge about
libipt_MARK.c is probably useful.

The full bug-report is available at:
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=510924

In iproute2's tc/m_ipt.c there's a function called get_target_name with
some logic to look up a symbol with the same name as the so-file. (ie.
"mark" for libipt_MARK.so or libxt_MARK.so).
There seems to have been a structure with that name in the past, but
nowadays there are several ones which are jacked in with a registration
hook.

Does this sound about right? Do you have any suggestions on how the tc
modules functionality could be fixed up to find what it needs properly?
The structures doesn't even seem to be exported in the ABI anymore...

-- 
Regards,
Andreas Henriksson
