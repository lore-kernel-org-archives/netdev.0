From: David Greaves <david@dgreaves.com>
Subject: 2.6.22-rc4 hibernate disables skge wol
Date: Fri, 15 Jun 2007 22:50:48 +0100
Message-ID: <467309B8.2060001@dgreaves.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-pm <linux-pm@lists.osdl.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:57403 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756870AbXFOVuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 17:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've started a new thread here since the old one got somewhat hijacked.

Rafael J. Wysocki wrote:
 > On Friday, 1 June 2007 23:23, David Greaves wrote:
 >> Not a regression though, it does it in 2.6.21
 >>
 >> If I cause the system to save state to disk then whilst off it no longer
 >> responds to g-wol.
 >
 > Can you please try with the hibernation and suspend patch series from
 >
 > http://www.sisk.pl/kernel/hibernation_and_suspend/2.6.22-rc3/patches/
 >
 > applied?
 >
 > Greetings,
 > Rafael
 >
 >
Now, IIRC, some time ago you asked me to try some patches :)

So I applied them (and Tejun's fixes as per the old thread) to rc4 (which seems 
to include a couple already).

Hibernate/resume works but although WOL works on an init 0, it doesn't work on a 
hibernated system :(

David

