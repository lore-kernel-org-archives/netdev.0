From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 17622] New: snmp trap ALG issue
Date: Fri, 17 Sep 2010 14:08:56 +0200
Message-ID: <4C935A58.8040208@trash.net>
References: <20100914163208.2ba165ca.akpm@linux-foundation.org>	<bug-17622-10286@https.bugzilla.kernel.org/>	<6029e4.25bb.12b1d97358d.Coremail.wtweeker@163.com> <20100916223909.68e5c557@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wtweeker@163.com, akpm@linux-foundation.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39350 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801Ab0IQMJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 08:09:02 -0400
In-Reply-To: <20100916223909.68e5c557@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 17.09.2010 07:39, schrieb Stephen Hemminger:
> nf_nat_snmp: use existing checksum update code
> 
> The fast_csum() in NAT code for processing SNMP trap is buggy 
> (see https://bugzilla.kernel.org/show_bug.cgi?id=17622)
> Replace it by using the existing checksum replacement code;
> it means adding a new csum_replace1() inline wrapper.

Applied, thanks Stephen.
