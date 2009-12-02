From: Lorenzo Allegrucci <lorenzo.allegrucci@forinicom.it>
Subject: match SIP & RTP packets
Date: Wed, 02 Dec 2009 23:38:07 +0100
Message-ID: <4B16EC4F.4080703@forinicom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host130-230-149-62.serverdedicati.aruba.it ([62.149.230.130]:36238
	"EHLO mail.wedoit.us" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbZLBWqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 17:46:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all, it's not clear to me whether nf_conntrack_sip does SIP and RTP connection
tracking or just SIP.. can you clarify?
I need to match both SIP and RTP packets and I was wondering if the rule
below would satisfy my requirements:

iptables -t mangle -A FORWARD -o eth0 -m helper --helper sip -j CLASSIFY --set-class 1:1


Thank you,
