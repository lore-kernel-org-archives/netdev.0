From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] NetXen: Fixes for ppc architecture.
Date: Fri, 02 Feb 2007 08:34:02 -0500
Message-ID: <45C33DCA.9000801@garzik.org>
References: <200701311831.l0VIVjch005677@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
To: "Amit S. Kale" <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48352 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423065AbXBBNeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:34:05 -0500
In-Reply-To: <200701311831.l0VIVjch005677@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> NetXen: Fixes for ppc architecture.
> 
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> 
> ---
> 
> Sorry, I wanted to send only one patch so please ignore [PATCH 0/2] in the
> subject of my last mail. It should be [PATCH 0/1].
> 
>  netxen_nic.h      |   98 ++++++++++++++++++++++++++++++++----------------------
>  netxen_nic_hw.c   |   31 ++++++++---------
>  netxen_nic_init.c |   19 +++++-----
>  netxen_nic_main.c |    7 ++-
>  netxen_nic_niu.c  |    2 -
>  5 files changed, 91 insertions(+), 66 deletions(-)

Patch does not apply to latest vanilla linux-2.6.git:

[jgarzik@pretzel netdev-2.6]$ git-am --signoff --utf8 /g/tmp/mbox

Applying 'NetXen: Fixes for ppc architecture.'

error: patch failed: drivers/net/netxen/netxen_nic.h:246
error: drivers/net/netxen/netxen_nic.h: patch does not apply
error: patch failed: drivers/net/netxen/netxen_nic_hw.c:236
error: drivers/net/netxen/netxen_nic_hw.c: patch does not apply
error: patch failed: drivers/net/netxen/netxen_nic_init.c:690
error: drivers/net/netxen/netxen_nic_init.c: patch does not apply
error: patch failed: drivers/net/netxen/netxen_nic_main.c:818
error: drivers/net/netxen/netxen_nic_main.c: patch does not apply
Patch failed at 0001.
When you have resolved this problem run "git-am --resolved".
If you would prefer to skip this patch, instead run "git-am --skip".

