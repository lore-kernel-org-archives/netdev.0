From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 01/13] qla3xxx: Return proper error codes when the 4022/4032
 is being probed
Date: Tue, 27 Feb 2007 04:22:07 -0500
Message-ID: <45E3F83F.6010003@garzik.org>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org> <11725168032993-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, benjamin.li@qlogic.com,
	netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47459 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161078AbXB0JWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:22:10 -0500
In-Reply-To: <11725168032993-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
> From: Benjamin Li <benjamin.li@qlogic.com>
> 
> The return code was not properly set when when allocating memory or mapping
> memory failed.  Depending on the stack, the return code would sometimes
> return 0, which indicates everything was ok, when in fact there was an error.
>   This would cause trouble when the module was removed.  Now, we will pass
> back the proper return code when an error occurs during the PCI probe.
> 
> Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qla3xxx.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)

applied 1-13


