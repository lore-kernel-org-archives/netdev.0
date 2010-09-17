From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 17622] New: snmp trap ALG issue
Date: Fri, 17 Sep 2010 08:31:25 -0700
Message-ID: <20100917083125.0d565a2d@nehalam>
References: <20100914163208.2ba165ca.akpm@linux-foundation.org>
	<bug-17622-10286@https.bugzilla.kernel.org/>
	<6029e4.25bb.12b1d97358d.Coremail.wtweeker@163.com>
	<20100916223909.68e5c557@nehalam>
	<4C935A58.8040208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wtweeker@163.com, akpm@linux-foundation.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60086 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753877Ab0IQPb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 11:31:27 -0400
In-Reply-To: <4C935A58.8040208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Sep 2010 14:08:56 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Am 17.09.2010 07:39, schrieb Stephen Hemminger:
> > nf_nat_snmp: use existing checksum update code
> > 
> > The fast_csum() in NAT code for processing SNMP trap is buggy 
> > (see https://bugzilla.kernel.org/show_bug.cgi?id=17622)
> > Replace it by using the existing checksum replacement code;
> > it means adding a new csum_replace1() inline wrapper.
> 
> Applied, thanks Stephen.

As I said in the patch, this was compile tested only. It would
be good if the original Bug submitter validated that this
fixed the problem.

-- 
