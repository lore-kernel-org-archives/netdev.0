From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 09:16:12 +0300
Message-ID: <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com> <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34427 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941326AbdDTGQN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 02:16:13 -0400
Received: by mail-oi0-f52.google.com with SMTP id x184so36096097oia.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 23:16:12 -0700 (PDT)
In-Reply-To: <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 4:57 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>
> Dump some internal state about VFs through debugfs. This provides
> information not available with 'ip link show'.

such as?

donnwantobethedebugfspolice, but still, in the 2-3 times we tried to
push debugfs to MLNX NIC
drivers, Dave disallowed that, and lately the switch team even went
further and deleted that
portion of the mlxsw driver -- all to all,  I don't see much point for
these type of changes, thoughts?
