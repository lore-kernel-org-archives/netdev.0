From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] vortex_up should initialize "err"
Date: Wed, 17 Oct 2007 20:28:36 -0400
Message-ID: <4716A8B4.5060406@garzik.org>
References: <1192662956.14504.14.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60271 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759530AbXJRA2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:28:42 -0400
In-Reply-To: <1192662956.14504.14.camel@dyn9047017100.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Badari Pulavarty wrote:
> Simple compile warning fix. (against 2.6.23-git12)
> 
> Thanks,
> Badari
> 
> vortex_up() should initialize 'err' for a successful return.
> 
> drivers/net/3c59x.c: In function `vortex_up':
> drivers/net/3c59x.c:1494: warning: `err' might be used uninitialized in this function

applied as an obvious bug fix (Steffen added to CC)

