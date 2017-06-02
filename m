From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [net,V2] vxlan: fix use-after-free on deletion
Date: Thu, 01 Jun 2017 20:31:12 -0700
Message-ID: <5930DC00.5090201@cumulusnetworks.com>
References: <1496363048-21138-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, roid@mellanox.com, netdev@vger.kernel.org
To: Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33888 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751122AbdFBDbP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 23:31:15 -0400
Received: by mail-pf0-f177.google.com with SMTP id 9so44430640pfj.1
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 20:31:14 -0700 (PDT)
In-Reply-To: <1496363048-21138-1-git-send-email-markb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17, 5:24 PM, Mark Bloch wrote:
> Adding a vxlan interface to a socket isn't symmetrical, while adding
> is done in vxlan_open() the deletion is done in vxlan_dellink().
> This can cause a use-after-free error when we close the vxlan
> interface before deleting it.
>
> We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
> it from vxlan_stop() to match the call from vxlan_open().
>
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Acked-by: Jiri Benc <jbenc@redhat.com>
> Tested-by: Roi Dayan <roid@mellanox.com>
> Signed-off-by: Mark Bloch <markb@mellanox.com>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
