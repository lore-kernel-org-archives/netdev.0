From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3] ibmvnic: Enable scatter-gather support
Date: Fri, 27 Oct 2017 10:05:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00A69AC@AcuExch.aculab.com>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <1508261816-3145-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD009AA16@AcuExch.aculab.com>
 <e5015ac2-d0f7-ff95-eea5-1adbedb13dc9@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Thomas Falcon' <tlfalcon@linux.vnet.ibm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:53131 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdJ0KE6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 06:04:58 -0400
In-Reply-To: <e5015ac2-d0f7-ff95-eea5-1adbedb13dc9@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon
> Sent: 26 October 2017 18:52
...
> >>  	memset(dst, 0, adapter->req_mtu);
> > Seems unnecessary.
> 
> I removed that bit, and so far you seem to be right :) .

I'd check that short frames are padded with zeros.

	David
