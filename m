From: Jeff Gustafson <ncjeffgus@zimage.com>
Subject: ESFQ (or SFQ updates) mainline status?
Date: Fri, 04 Jan 2008 11:21:15 -0800
Message-ID: <1199474475.3820.65.camel@sally>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.zimage.com ([216.86.199.5]:59814 "EHLO alpha.zimage.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297AbYADTwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 14:52:41 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by alpha.zimage.com (Postfix) with ESMTP id 1BF861C2960
	for <netdev@vger.kernel.org>; Fri,  4 Jan 2008 11:21:33 -0800 (PST)
Received: from alpha.zimage.com ([127.0.0.1])
 by localhost (alpha.zimage.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 11332-03 for <netdev@vger.kernel.org>;
 Fri,  4 Jan 2008 11:21:26 -0800 (PST)
Received: from [192.168.0.3] (mail.idc-global.com [66.92.217.130])
	by alpha.zimage.com (Postfix) with ESMTP id C3B181C291D
	for <netdev@vger.kernel.org>; Fri,  4 Jan 2008 11:21:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
	I have a question about the status of the spiffy updates to SFQ.  I
*really* like the ESFQ idea.  I appears to be exactly what I'm looking
for.  From what I can tell from this mailing list, SFQ is getting some
or all of the ESFQ features.  Although the ESFQ web site gives detailed
information about the status for inclusion in mainline, I am having
trouble finding out exactly what (if any) parts of ESFQ got into SFQ in
mainline.
	Did any of the ESFQ-like enhancements for SFQ reach .23 or do I still
need to patch?  I am running a stripped-down Fedora 8 box and it would
be very convenient if the patches were already in .23 or added by the
Fedora team.
	I tried to run the ESFQ command against SFQ, but the command was
rejected:

/sbin/tc qdisc add dev eth1 parent 1:12 handle 12: sfq perturb 10 hash
ctnatchg

	It appears the even if the kernel does have the patches, the shipped
version tc does not.

				..Jeff


