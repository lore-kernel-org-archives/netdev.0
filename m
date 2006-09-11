From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] pcnet32: NAPI implementation
Date: Mon, 11 Sep 2006 09:01:59 -0400
Message-ID: <45055E47.5010303@pobox.com>
References: <20060908223954.GA24364@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:28337 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751452AbWIKNCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 09:02:04 -0400
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20060908223954.GA24364@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Implement NAPI changes to pcnet32 driver.  Compile default is off.
> Listed as experimental.
> 
> Len and Don both worked on a NAPI implementation and have both tested
> these changes. 
> 
> An e1000 blasting short packets to the pcnet32 will lockup Don's system
> until the receive storm stops.  Without NAPI Len's system watchdog would
> expire causing the system to reboot.  With NAPI the system will stay
> operational.
> 
> Tested ia32 and ppc64.  Tested '970A, '971, '972, '973, '975, '976, and
> '978.
> 
> The Kconfig changes came from Len.  Don is to blame for all the others.
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>
> Signed-off-by: Don Fry <brazilnut@us.ibm.com>

Please break this up into two patches:  one patch breaks code out into 
separate functions, but does not functionality at all.  second patch 
implements NAPI.

otherwise OK

	Jeff



