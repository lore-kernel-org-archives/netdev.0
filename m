From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Should driver set CHECKSUM_COMPLETE for TCP pakcets
Date: Tue, 18 Aug 2015 06:44:59 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DFEB62@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: "Tom Herbert (Partner - google)" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49653 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791AbbHRGpD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 02:45:03 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider a device that doesn't provide the complete checksum for
entire Rx packets, but does verify the checksums for several protocols.

Now, assuming the HW is capable of verifying TCP checksums -
Should the driver calculate the pseudo TCP checksum for such packets
and pass those as COMPLETE? Or should it stick to UNNECESSRAY?

[Specifically I'm interested for this for the FW gro implementation -
it might be possible to mark an entire aggregation as COMPLETE]

Thanks,
Yuval
