From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 3/8] netback: get/put module along with vif
 connect/disconnect
Date: Tue, 5 Mar 2013 10:02:48 +0000
Message-ID: <5135C2C8.8030708@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com> <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10716 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635Ab3CEKCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 05:02:51 -0500
In-Reply-To: <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/13 16:00, Wei Liu wrote:
> If there is vif running and user unloads netback, guest's network interface
> just mysteriously stops working. So we need to prevent unloading netback
> module if there is vif running.

It's not mysterious -- it is cleanly disconnected, and will reconnect
when the module is reinserted.

Being able to unload modules while they are in use is standard so I
don't think this should be applied.

David
