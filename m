From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] Use the pause counter to avoid a needless device
 reset
Date: Tue, 14 Aug 2007 01:28:39 -0400
Message-ID: <46C13D87.30103@garzik.org>
References: <46BABBCA.2060001@myri.com> <46BABBF6.30001@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46924 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S940351AbXHNF2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:28:41 -0400
In-Reply-To: <46BABBF6.30001@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Use the pause counter to avoid a needless device reset, and
> print a message telling the admin that our link partner is
> flow controlling us down to 0 pkts/sec.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   25 ++++++++++++++++++-------
>  1 file changed, 18 insertions(+), 7 deletions(-)

applied

please prefix your subject lines like this:

	[PATCH m/n] myri10ge:

so that the automated tools (git-am from the git package) properly 
provide a one-line summary for your patch.  for more info also see
http://linux.yyz.us/patch-format.html
