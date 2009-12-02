From: Tore Anderson <tore.anderson@redpill-linpro.com>
Subject: "NIG timer max" messages from bnx2x
Date: Wed, 02 Dec 2009 17:00:04 +0100
Message-ID: <4B168F04.60309@redpill-linpro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.linpro.no ([87.238.49.141]:48045 "EHLO
	mailhub.linpro.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639AbZLBQ2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 11:28:51 -0500
Received: from localhost (mailhub.linpro.no [87.238.49.141])
	by mailhub.linpro.no (Postfix) with ESMTP id 5CFEB1DE51D
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2009 17:00:15 +0100 (CET)
Received: from mailhub.linpro.no ([87.238.49.141])
	by localhost (mailhub.linpro.no [87.238.49.141]) (amavisd-new, port 10024)
	with ESMTP id 4Fr18N5j6J1T for <netdev@vger.kernel.org>;
	Wed,  2 Dec 2009 17:00:07 +0100 (CET)
Received: from zimbra.redpill-linpro.com (claudius.linpro.no [87.238.49.234])
	by mailhub.linpro.no (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2009 17:00:07 +0100 (CET)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra.redpill-linpro.com (Postfix) with ESMTP id 3105D170C004
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2009 17:00:07 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello list,

I'm having a strange error condition I'm hoping someone here might be
able to help me get to the bottom of.  I've got a HP blade enclosure
with a Nortel switch module, and one of the blades are running VMWare
ESX.  When I turn on this blade (or enable its switch port), the entire
network stops working after a short while.  Other server blades can no
longer communicate, for instance.  The only clue I've found so far is
the following error message from one of the other blades that's running
CentOS 5.4:

[bnx2x_hw_stats_update:3701(eth0)]NIG timer max (426)

The line is logged every two seconds and the number in parenthesis is
incrementing each time.  Once I disable the port to the ESX server, the
network instantly recovers.

I have no reason to believe the Linux kernel/bnx2x is doing anything
wrong here, but I'm wondering if anybody has any idea on what this error
message means and what could be causing it?  I can't see anything
unusual going on with tcpdump, and the error counters in "ip -s -s link
show eth0" are all zero.

Best regards,
-- 
Tore Anderson
Redpill Linpro AS - http://www.redpill-linpro.com/
Tel: +47 21 54 41 27
