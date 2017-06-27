From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next v2 6/6] ixgbe: Add malicious driver detection support
Date: Tue, 27 Jun 2017 12:07:43 +0300
Message-ID: <CAJ3xEMiEjGDUatUv47wNTfYPfCVo62+Jjs-xFU3ccN0iJm-5Gg@mail.gmail.com>
References: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com> <20170627085131.9831-7-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Paul Greenwalt <paul.greenwalt@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35384 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751553AbdF0JHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 05:07:44 -0400
Received: by mail-oi0-f42.google.com with SMTP id c189so14016227oia.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 02:07:44 -0700 (PDT)
In-Reply-To: <20170627085131.9831-7-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 11:51 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Paul Greenwalt <paul.greenwalt@intel.com>
>
> Add malicious driver detection (MDD) support for X550, X550em_a,
> and X550em_x devices.
>
> MDD is a hardware SR-IOV security feature which the driver enables by
> default, but can be controlled on|off by ethtool set-priv-flags

wait, we have the trusted vf concept, which you implement
(ixgbe_ndo_set_vf_trust)
so you can enable by default for all vfs and disable it for trusted
ones, why create
an ixgbe special config knob? IMHO we should max all possible efforts to avoid
priv ethtool flags usage.


Or.
