From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 5/6] i40e: Add TX and RX support in switchdev mode.
Date: Thu, 5 Jan 2017 14:08:54 +0200
Message-ID: <CAJ3xEMiSt2a9rQYpjtu=o8YBA2YjPD=6nSwBnh5gfuseQwXCcQ@mail.gmail.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com> <1483466874-2962-6-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        David Miller <davem@davemloft.net>,
        intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        jakub.kicinski@netronome.com,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34318 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970675AbdAEMI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 07:08:56 -0500
Received: by mail-oi0-f66.google.com with SMTP id 3so49874325oih.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 04:08:55 -0800 (PST)
In-Reply-To: <1483466874-2962-6-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2017 at 8:07 PM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> A host based switching entity like a linux bridge or OVS redirects these frames
> to the right VFs via VFPR netdevs. Any frames sent via VFPR netdevs are sent as
> directed transmits to the corresponding VFs. To enable directed transmit, skb
> metadata dst is used to pass the VF id and the frame is requeued to call the PFs
> transmit routine.

Jakub/John, patch #4 which didn't appear in the list had a long discussion [1]
ending  with "lets talk on it @ netdev", did we?

Or.

[1] http://marc.info/?t=147457252900002&r=1&w=2
