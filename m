From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: linux-next: next-20160301: unregister_netdevice: waiting for lo
 to become free. Usage count = 2
Date: Tue, 1 Mar 2016 12:07:49 -0800
Message-ID: <20160301200749.GA1611@hudson.localdomain>
References: <6c735168f53548a39bd21e6e9857f512@HKXPR3004MB0088.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34397 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbcCAUHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:07:52 -0500
Received: by mail-pa0-f43.google.com with SMTP id fy10so117728927pac.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 12:07:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6c735168f53548a39bd21e6e9857f512@HKXPR3004MB0088.064d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On Tue, Mar 01, 2016 at 08:11:54AM +0000, Dexuan Cui wrote:
> Hi, I got this line every 10 seconds with today's linux-next in a Hyper-V guest, even
> when I didn't configure any NIC for the guest:
>  
> [   72.604249] unregister_netdevice: waiting for lo to become free. Usage count = 2
> [   82.708170] unregister_netdevice: waiting for lo to become free. Usage count = 2
> [   92.788079] unregister_netdevice: waiting for lo to become free. Usage count = 2
> [  102.808132] unregister_netdevice: waiting for lo to become free. Usage count = 2
> [  112.928166] unregister_netdevice: waiting for lo to become free. Usage count = 2
> [  122.952069] unregister_netdevice: waiting for lo to become free. Usage count = 2
> 
> I don't think this is related to the underlying host, since it's related to "lo".
> 
> This should be a recent regression, as I remember the January linux-next didn't have
> this issue.
> 
> Any idea?
> 
> The gzip-ed kernel config is attached FYI.
> 
> Thanks,
> -- Dexuan
> 

Just a "me too", but I have this problem on a Lenovo Carbon X1 when
running linux-next 20160301.  It worked with 20160225.

I can test patches and I will try to bisect the problem as time allows.

-- 
- Jeremiah Mahler
