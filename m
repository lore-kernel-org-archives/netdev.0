From: Gal Pressman <galp.dev@gmail.com>
Subject: Re: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to
 ethtool
Date: Thu, 22 Jun 2017 11:33:39 +0300
Message-ID: <311af079-cf95-b487-f59a-9566e17296bf@gmail.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-4-git-send-email-galp@mellanox.com>
 <20170621213353.318e5d37@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Jakub Kicinski <kubakici@wp.pl>, Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34795 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdFVIdn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 04:33:43 -0400
Received: by mail-wr0-f194.google.com with SMTP id k67so2790850wrc.1
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 01:33:43 -0700 (PDT)
In-Reply-To: <20170621213353.318e5d37@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Is my reading correct that in case the reason is not in the
> pddr2ethtool_table opaque binary data will be passed from the firmware
> to user space?  Is there any particular reason to allow for this?  If
> it's just for the rare scenario where a new error code needs to be
> added perhaps it would be enough to dump the FW-provided message to the
> logs?

No binary data is passed in this patch, the monitor_opcode is simply a vendor specific
16 bit id that is used when the reason  is not generic enough to have it's own enum.
