From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: no IPv6 Routers present
Date: Thu, 12 Mar 2009 22:05:56 +0100
Message-ID: <gpbtfk$s5h$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40076 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbZCLVKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 17:10:12 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LhsAE-00032G-HV
	for netdev@vger.kernel.org; Thu, 12 Mar 2009 21:10:03 +0000
Received: from dslb-092-076-238-059.pools.arcor-ip.net ([92.76.238.59])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 21:10:02 +0000
Received: from feldmann_markus by dslb-092-076-238-059.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 21:10:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

i am working on a combined Firewall, means
2 Firewalls on one Personal Computer.

The first firewall is for my <ppp0> and
the second firewall is for <eth0> if i connect
through my Server to the internet.

However, if i plug off and plug in my network
cable, to change the connection from <eth0> to
<ppp0>, the connection to internet fails.
 From <ppp0> to <eth0> works, but than i can
not switch back because of a unkown connection
error.

<dmesg> prints out:
no IPv6 Router present

Ok maybe this is true. There is no IPv6 Router
in my lan, but why do my Kernel not switch back
to IPv4 ?

How can i correct this ?
I do not want to disable the whole IPv6 kernel/program
options.

Is this a Bug ?

