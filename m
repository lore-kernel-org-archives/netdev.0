From: Kenneth Lee <Kenneth-Lee-2012@foxmail.com>
Subject: Re: Fwd: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once
 HANDEL_TX_MSG macro
Date: Thu, 15 Oct 2015 23:32:36 +0800
Message-ID: <20151015153236.GA3989@kllt-03>
References: <6398202.hrOAl1xuJE@wuerfel>
 <561CAD6D.2060105@hisilicon.com>
 <20151013132712.GA3310@kllt-03>
 <6914069.XLdT9Eli48@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	huangdaode <huangdaode@hisilicon.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:35127 "EHLO
	smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbbJOPcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:32:51 -0400
Content-Disposition: inline
In-Reply-To: <6914069.XLdT9Eli48@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 04:18:23PM +0200, Arnd Bergmann wrote:
> Date: Tue, 13 Oct 2015 16:18:23 +0200
> From: Arnd Bergmann <arnd@arndb.de>
> To: Kenneth Lee <Kenneth-Lee-2012@foxmail.com>
> Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
>  Yisen.Zhuang@huawei.com, netdev@vger.kernel.org, linuxarm@huawei.com,
>  salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
>  xuwei5@hisilicon.com, lisheng011@huawei.com, linux-kernel@vger.kernel.org,
>  huangdaode <huangdaode@hisilicon.com>
> Subject: Re: Fwd: Re: [PATCH net-next v2 1/2] hisilicon net: removes the
>  once HANDEL_TX_MSG macro
> Message-ID: <6914069.XLdT9Eli48@wuerfel>
> 
> On Tuesday 13 October 2015 21:27:12 Kenneth Lee wrote:
> > 
> > Hi, Arnd,
> > 
> > Thank you for the comment. Yes, the io_base is a security problem, we
> > will fix it in coming patch soon.
> > 
> > But can we keep the sysfs? The interface from hnae is not used only by
> > ethernet driver but also by Open Data Plane driver. If we more it to
> > upper layers. Both drivers will have the same logic. 
> > 
> > So how about we just add documents to Documention/ABI?
> 
> Hi Kenneth,
> 
> In the end this is up to David Miller of course, but I'd say we are
> better off not introducing any ABIs for ODP prematurely.
> 
> We are talking about very generic statistics data, and you should
> already provide them for the ethernet driver using the standard
> interfaces.
> 
> I have not seen any discussion about adding an ODP subsystem for
> the Linux kernel, or what the API will be, but I think we should
> not export any interfaces from a particular device driver directly
> but always go through a common layer here and use an extensible
> interface that can be implemented by everyone.
> 
> The API has not been part of a release yet, so I'd say we should
> remove it for now. Once we have a net/odp/ directory, we can
> add a driver-independent implementation there and call it from
> the hisi driver.
> 
> 	Arnd

Hi, Arnd,

Agree. We will remove the interface for the time being. Thank you.

-- 
			-Kenneth Lee (Hisilicon)
