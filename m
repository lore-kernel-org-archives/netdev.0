From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH V3 net-next 0/2] liquidio: switchdev support for
 LiquidIO NIC
Date: Tue, 31 Oct 2017 16:30:11 -0700
Message-ID: <20171031163011.750b3753@cakuba.netronome.com>
References: <20171031230420.GA3615@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:46756 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932532AbdJaXaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 19:30:15 -0400
Received: by mail-qt0-f174.google.com with SMTP id 1so809807qtn.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 16:30:15 -0700 (PDT)
In-Reply-To: <20171031230420.GA3615@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 16:04:20 -0700, Felix Manlunas wrote:
> From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
> 
> patch1 of this patch set adds switchdev support for SRIOV capable
> LiquidIO NIC, so that for every SRIOV VF on LiquidIO, a representor
> netdev is created on hypervisor. It also has changes to send representor
> interface configurations like admin state and MTU to LiquidIO firmware and
> to retrieve HW counted VF stats for VF representor.
> 
> patch2 adds support for switchdev enable/disable from devlink
> 
> Patchset Change Log:
>   V2 -> V3:
>     * Use mac address as the physical switchID.
>     * Check for eswitch_mode before returning switchID

Looks better, thanks!
