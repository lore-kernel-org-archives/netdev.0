From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] remove irq_sem from atl1
Date: Tue, 27 Feb 2007 04:32:40 -0500
Message-ID: <45E3FAB8.2090504@garzik.org>
References: <20070220.4mi.25231800@egw.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jacliburn@bellsouth.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47605 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161077AbXB0Jcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:32:48 -0500
In-Reply-To: <20070220.4mi.25231800@egw.corp.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Remove unnecessary irq_sem code from atl1 driver.  Tested with no problems.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

ACK, but patch does not apply:


Applying 'remove irq_sem from atl1'

error: patch fragment without header at line 7: @@ -236,7 +236,6 @@ 
struct atl1_adapter {
error: patch fragment without header at line 21: @@ -163,7 +163,6 @@ 
static int __devinit atl1_sw_init(struct
error: patch fragment without header at line 29: @@ -272,8 +271,7 @@ 
err_nomem:
error: patch fragment without header at line 39: @@ -1205,7 +1203,6 @@ 
static u32 atl1_configure(struct atl1_ad
error: No changes
Patch failed at 0004.
When you have resolved this problem run "git-am --resolved".
If you would prefer to skip this patch, instead run "git-am --skip".
