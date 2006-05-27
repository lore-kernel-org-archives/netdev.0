From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/5] s390: lcs driver bug fixes and improvements [1/2]
Date: Fri, 26 May 2006 21:58:52 -0400
Message-ID: <4477B25C.6020301@pobox.com>
References: <20060524095117.3b6b24cd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:1252 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751759AbWE0B6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 21:58:54 -0400
To: Frank Pavlic <fpavlic@de.ibm.com>
In-Reply-To: <20060524095117.3b6b24cd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> 
> From: Klaus Wacker <kdwacker@de.ibm.com>
> 
> 	Several problems occured with lcs device driver:
> 	 - device not operational anymore after cable pull/plug-in.
>        	 - unpredictable results occured, e.g. kernel panic
> 	   using cards of type QD8F.
> 	 - STOPLAN and delete multicast address command
>            were not proper recognized by OSA card under heavy network workload.
>        	 - channel/device error checks missing in interrupt handler.
> 	To fix all problems at once recovery of lcs devices has been improved.
> 	missing error checks in lcs interrupt handler has been added.
> 	Once a hardware problem occurs lcs will recover the device now properly.
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

applied 4-5


