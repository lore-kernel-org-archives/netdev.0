From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: Question: Proper place for port details?
Date: Thu, 04 Oct 2012 10:28:06 +0200
Message-ID: <506D4896.8080900@linux.vnet.ibm.com>
Reply-To: raspl@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:54518 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964998Ab2JDI2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 04:28:10 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Thu, 4 Oct 2012 09:28:09 +0100
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q948Rxqi57868324
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 08:27:59 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q948S6mD025770
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 02:28:06 -0600
Received: from [9.152.224.20] (dyn-9-152-224-20.boeblingen.de.ibm.com [9.152.224.20])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q948S6sq025757
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 02:28:06 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some network device drivers are capable of collecting further
information on the link partner, e.g. reporting details on the port
in the adjacent switch. Is there a good place to make these
available outside of the kernel? ethtool gives a bit of information
like the link partner's speed or duplex mode. But is adding further
information about the link partner to ethtool desired, or is there a
better place somewhere else?

Ciao,
Stefan
