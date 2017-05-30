From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 0/7] bnxt_en: Misc. updates for net-next.
Date: Mon, 29 May 2017 20:45:02 -0700
Message-ID: <CACKFLim_Ljd4d50zk_76UDZLk=GQQKnRCmmCCdbUhTOPBZ5NXg@mail.gmail.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com> <20170529.232442.2063879282909901778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:35025 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdE3DpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:45:04 -0400
Received: by mail-lf0-f51.google.com with SMTP id a5so42186850lfh.2
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 20:45:04 -0700 (PDT)
In-Reply-To: <20170529.232442.2063879282909901778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 29, 2017 at 8:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Mon, 29 May 2017 19:06:03 -0400
>
>> The 1st 2 patches add short firmware message support for new VF devices.
>> The 3rd patch adds a pci shutdown callback for the RDMA driver for proper
>> shutdown.  The next 3 patches improve the doorbell operations by
>> elimiating the double doorbell workaround on newer chips, and by adding
>> xmit_more support.  The last patch adds a parameter to bnxt_set_dflt_rings().
>
> Series applied, but where is the change that sets the new ulp_shutdown
> method pointer to something?
>

That will be done by the bnxt_re maintainers through the RDMA tree.
They are still working on it.
