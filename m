From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NFS over NAT causes e1000e transmit hangs
Date: Tue, 18 Apr 2017 12:03:24 -0700
Message-ID: <1492542204.10587.138.camel@edumazet-glaptop3.roam.corp.google.com>
References: <42af0e78-3107-1605-f8e1-d73a8c441ff0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35207 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdDRTD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:03:26 -0400
Received: by mail-pf0-f170.google.com with SMTP id i5so901906pfc.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 12:03:26 -0700 (PDT)
In-Reply-To: <42af0e78-3107-1605-f8e1-d73a8c441ff0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 11:18 -0700, Florian Fainelli wrote:
> Hi,
> 
> I am using NFS over a NAT with two e1000e adapters and with eth1 being
> the LAN interface and eth0 the WAN interface. The kernel is Ubuntu's
> 16.10 kernel: 4.8.0-46-generic. The device doing NAT over NFS is just
> mounting a remote folder and doing normal execution/file accesses. It's
> enough to untar a file from this device onto a NFS share to expose the
> problem.
> 
> The transmit hangs look like the ones below, doing a rmmod/insmod does
> not help eliminated the problem, nor does a power cycle. Stopping the
> NFS over NAT definitively does let the adapter recover.

Is this NFS over TCP or UDP ?

Thanks !
