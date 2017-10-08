From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: devlink dump of mlxsw_adj table triggers a panic
Date: Sun, 8 Oct 2017 10:43:08 +0300
Message-ID: <c7286c2b-09de-1221-303a-0aed3ed77c21@mellanox.com>
References: <78e0bce8-e122-ab92-2f48-e9d278f4d2b4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0042.outbound.protection.outlook.com ([104.47.0.42]:20944
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750997AbdJHHnP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 03:43:15 -0400
In-Reply-To: <78e0bce8-e122-ab92-2f48-e9d278f4d2b4@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/05/2017 02:57 AM, David Ahern wrote:
> The following devlink command on a 2700 triggers a panic every time.
> Kernel is net-next at 26873308b21654b6e0785b9f9e2c5414d37a4c4c
> 
> $ devlink  dpipe table dump pci/0000:03:00.0 name mlxsw_adj
> devlink answers: No buffer space available
> <hang>
> 
> I have seen several different stack traces and varying amounts of EMAD
> errors on console:
> 
> [   77.453364] mlxsw_spectrum 0000:03:00.0: EMAD reg access failed
> (tid=64c24a400003688,reg_id=200b(sfn),type=query,status=0(operation
> performed))
> [   77.466568] mlxsw_spectrum 0000:03:00.0: Failed to get FDB notifications
> 
> If it does not reproduce for you let me know and I'll grab a trace.
> 
> David
> 

Thanks, will check it out. How many nexthops groups & overall number of
nexthops you configured?

Thanks,
Arkadi
