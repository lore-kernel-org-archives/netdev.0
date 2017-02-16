From: Marty Plummer <netz.kernel@gmail.com>
Subject: Re: net: hix5hd2_gmac uninitialized net_device
Date: Thu, 16 Feb 2017 12:45:03 -0600
Message-ID: <20170216184503.7ujdlkpfryu6ivwt@tha-monstah.mydomain>
References: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
 <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
 <589D942F.7070700@hisilicon.com>
 <20170211005132.xdk2d7etb732scqo@tha-monstah.mydomain>
 <58A10B12.8050400@hisilicon.com>
 <20170214235954.xhuikgj4bbfjq7fv@tha-monstah.mydomain>
 <58A3F2A6.3060609@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36335 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933060AbdBPSoL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 13:44:11 -0500
Received: by mail-oi0-f67.google.com with SMTP id u143so2101255oif.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 10:44:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <58A3F2A6.3060609@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 02:18:14PM +0800, Dongpo Li wrote:
> Hi Marty,
> 
> On 2017/2/15 7:59, Marty Plummer wrote:
> > On Mon, Feb 13, 2017 at 09:25:38AM +0800, Dongpo Li wrote:
> Currently this driver can't support Hi3521a soc because of some new changes.
> I don't know what's your purpose to run hix5hd2 driver on Hi3521a, please ask
> the man who sells chips to you to raise your requirements.
>
Its not so much a matter of wanting to run the hix5hd2 driver on
hi3521a, but running the hix5hd2 ip core driver on the same/similar ip
core on hi3521a. This is fairly common in the arm world, and a number of
drivers support multiple arm socs/ip cores, some from hisilicon in fact.
For instance "hisilicon,fmc-spi-nor" supports both the hi3519 and the
hi3521a.

Also, I'm not buying chips or boards from Hisilicon. I'm just working on
some consumer electronics that happens to include a hisilicon soc and
unreleased gpl code, working to improve it.

Regards

Marty.
