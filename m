From: "Jenkins, Clive" <Clive.Jenkins@xerox.com>
Subject: RE: [PATCH 4/6] ehea: header files
Date: Tue, 15 Aug 2006 11:53:05 +0100
Message-ID: <35786B99AB3FDC45A821572461791973AC87D3@gbrwgceumf01.eu.xerox.net>
References: <44E19765.7030301@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Thomas Klein" <tklein@de.ibm.com>,
	"netdev" <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Marcus Eder" <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wvmler4.mail.xerox.com ([13.8.138.219]:60550 "EHLO
	wvmler4.mail.xerox.com") by vger.kernel.org with ESMTP
	id S1030212AbWHOKxg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 06:53:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <44E19765.7030301@de.ibm.com>
To: "Jan-Bernd Themann" <ossthema@de.ibm.com>, <michael@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > You mean the eHEA has its own concept of page size? Separate from
the
> > page size used by the MMU?
> > 
> 
> yes, the eHEA currently supports only 4K pages for queues

In that case, I suggest use the kernel's page size, but add a
compile-time
check, and quit with an error message if driver does not support it.

Regards,
Clive
