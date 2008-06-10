From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][2.6.26] ehea: set mac address fix
Date: Tue, 10 Jun 2008 18:21:54 -0400
Message-ID: <484EFE82.6080003@garzik.org>
References: <200806091617.38396.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, hering2@de.ibm.com
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38981 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293AbYFJWV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:21:57 -0400
In-Reply-To: <200806091617.38396.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan-Bernd Themann wrote:
> eHEA has to call firmware functions in order to change the mac address
> of a logical port. This patch checks if the logical port is up
> when calling the register / deregister mac address calls. If the port
> is down these firmware calls would fail and are therefore not executed.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied


