From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net] vxlan: fix use-after-free on deletion
Date: Thu, 1 Jun 2017 13:17:21 +0300
Message-ID: <CAJ3xEMgcDQQTetaR_DNLfZWnjHE=25in7bFcWWfx4tKpf+j4kg@mail.gmail.com>
References: <1496306615-770-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Benc <jbenc@redhat.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33221 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdFAKRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:17:23 -0400
Received: by mail-oi0-f41.google.com with SMTP id w10so48210562oif.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 03:17:22 -0700 (PDT)
In-Reply-To: <1496306615-770-1-git-send-email-markb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 11:43 AM, Mark Bloch <markb@mellanox.com> wrote:
> Adding a vxlan interface to a socket isn't symmetrical, while adding
> is done in vxlan_open() the deletion is done in vxlan_dellink().
> This can cause a use-after-free error when we close the vxlan
> interface before deleting it.
>
> We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
> it from vxlan_stop() to match the call from vxlan_open().
>

If you are fixing a specific commit, best to put a proper Fixes that here

> Signed-off-by: Mark Bloch <markb@mellanox.com>
