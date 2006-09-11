From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Mon, 11 Sep 2006 09:13:38 -0400
Message-ID: <45056102.2010408@pobox.com>
References: <20060906124447.642940bd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16818 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751474AbWIKNNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 09:13:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060906124447.642940bd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix problems with transmit pause frames. The driver was telling the
> GMAC to flush (not process) pause frames. Manually disabling pause wasn't
> working because of problems in the setup.
> 
> This maybe the cause of the lockup under load.
> 	http://bugzilla.kernel.org/show_bug.cgi?id=6839
> 
> Patch against netdev-2.6 git tree
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Is this for #upstream (2.6.19) or #upstream-fixes (2.6.18-rc)?

It looks OK for #upstream, but too intrusive for #upstream-fixes.

	Jeff



