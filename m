From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: fix byte order of vxlan-gpe port number
Date: Tue, 17 Jan 2017 11:15:59 +0100
Message-ID: <20170117111559.52d9edff@griffin>
References: <1484609878-7288-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46630 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750747AbdAQKQv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 05:16:51 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 757D87F76F
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:16:02 +0000 (UTC)
In-Reply-To: <1484609878-7288-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jan 2017 18:37:58 -0500, Lance Richardson wrote:
> vxlan->cfg.dst_port is in network byte order, so an htons()
> is needed here. Also reduced comment length to stay closer
> to 80 column width (still slightly over, however).

Ouch. A stupid mistake I made. I think it's still okay to fix this, I'm
not aware of anyone using VXLAN-GPE yet, it's main user is going to be
NSH which is still under development.

Acked-by: Jiri Benc <jbenc@redhat.com>

Please apply also to stable.

Thanks,

 Jiri
