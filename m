From: Marty Plummer <netz.kernel@gmail.com>
Subject: Re: net: hix5hd2_gmac uninitialized net_device
Date: Fri, 10 Feb 2017 18:51:33 -0600
Message-ID: <20170211005132.xdk2d7etb732scqo@tha-monstah.mydomain>
References: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
 <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
 <589D942F.7070700@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:36830 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdBKAvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 19:51:42 -0500
Received: by mail-ot0-f195.google.com with SMTP id 36so5394182otx.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 16:50:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <589D942F.7070700@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 06:21:35PM +0800, Dongpo Li wrote:
> I think the error "No irq resource" happened for some other reason, has no relation with
> the info "(unnamed net_device) (uninitialized):".
> You can add more debug info to find bug.
Do you have any particular suggestions as to what to check out, or is
this just a general 'debug more' instruction?
> Yes, I agree with you that the ndev has not been initialized completely,
> because the function "register_netdev" has not been called yet.
> It's better to use the "dev_err" to replace the "netdev_err".
>
Ah, I see. So, prior to line 1266's call to register_netdev, it will
always be uninitialized and unnamed, regardless of what is or isn't
right elsewhere. Good to know. So, I could replace these netdev_err
with dev_err for now, up until that point, so I can get a bit more info,
yes?
> 
>     Regards,
>     Dongpo
>

	Regards,
	Marty
