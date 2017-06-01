From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [net] vxlan: fix use-after-free on deletion
Date: Thu, 1 Jun 2017 10:53:08 +0200
Message-ID: <20170601105308.0be70eb4@griffin>
References: <1496306615-770-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>, <netdev@vger.kernel.org>
To: Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdFAIxM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 04:53:12 -0400
In-Reply-To: <1496306615-770-1-git-send-email-markb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Jun 2017 11:43:35 +0300, Mark Bloch wrote:
> Adding a vxlan interface to a socket isn't symmetrical, while adding
> is done in vxlan_open() the deletion is done in vxlan_dellink().
> This can cause a use-after-free error when we close the vxlan
> interface before deleting it.
> 
> We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
> it from vxlan_stop() to match the call from vxlan_open().
> 
> Signed-off-by: Mark Bloch <markb@mellanox.com>

Acked-by: Jiri Benc <jbenc@redhat.com>
