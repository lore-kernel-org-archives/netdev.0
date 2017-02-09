From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: Mellanox ConnectX-3 VF driver can't work with 16 CPUs?
Date: Thu, 9 Feb 2017 18:47:33 +0200
Message-ID: <032fd940-f0e8-4cd6-e455-8b8855c3105f@gmail.com>
References: <MWHPR03MB2669F7138EE9DE92A372C863BF450@MWHPR03MB2669.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dexuan Cui <decui@microsoft.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:34765 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932221AbdBIQrg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:47:36 -0500
Received: by mail-wr0-f170.google.com with SMTP id o16so87857634wra.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 08:47:36 -0800 (PST)
In-Reply-To: <MWHPR03MB2669F7138EE9DE92A372C863BF450@MWHPR03MB2669.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dexuan,


On 09/02/2017 12:03 PM, Dexuan Cui wrote:
> Hi,
> While trying SR-IOV with a Linux guest running on Hyper-V, I found this issue:
> the VF driver can't work if the guest has 16 virtual CPUs (less vCPUs, e.g. 8,  can work fine):
>
> [    9.927820] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
> [    9.927882] mlx4_core: Initializing b961:00:02.0
> [    9.970994] mlx4_core b961:00:02.0: Detected virtual function - running in slave mode
> [    9.976783] mlx4_core b961:00:02.0: Sending reset
> [    9.985858] mlx4_core b961:00:02.0: Sending vhcr0
> [   10.004855] mlx4_core b961:00:02.0: HCA minimum page size:512
> [   10.010465] mlx4_core b961:00:02.0: Timestamping is not supported in slave mode
> [   10.203065] mlx4_core b961:00:02.0: Failed to initialize event queue table, aborting
> [   10.226728] mlx4_core: probe of b961:00:02.0 failed with error -12
>
> I'm using the mainline kernel (4.10.0-rc4).
>
> Any idea?
Thanks for your report.
We'll check this internally and get back to you.

Regards,
Tariq
>
> Thanks,
> -- Dexuan
>
