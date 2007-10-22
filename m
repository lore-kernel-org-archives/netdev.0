From: wit <is01kzh@gmail.com>
Subject: Re: about multiple network interface
Date: Mon, 22 Oct 2007 23:07:53 +0800
Message-ID: <105610bf0710220807v42b8afabp8de6d6c93b785069@mail.gmail.com>
References: <105610bf0710180606w6a687642r35414d2b66b6d3af@mail.gmail.com>
	 <20071018132836.GA15906@2ka.mipt.ru>
	 <105610bf0710211909r6ab2b63fo8a4f67eba6c05bc7@mail.gmail.com>
	 <20071022091410.GB12186@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:11319 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbXJVPH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 11:07:56 -0400
Received: by nz-out-0506.google.com with SMTP id s18so447147nze
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 08:07:55 -0700 (PDT)
In-Reply-To: <20071022091410.GB12186@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thank you very much..

2007/10/22, Evgeniy Polyakov <johnpol@2ka.mipt.ru>:
> On Mon, Oct 22, 2007 at 10:09:38AM +0800, wit (is01kzh@gmail.com) wrote:
> > But this does work until I add a ifcfg-eth0 in
> > sysconfig/network-script with the following content:
> > DEVICE=eth0
> > ONBOOT=yes
> >
> > What is the relationship between these two files? And sometimes, I see
>
> It depends on your distro - when script calls "modprobe $DEVICE"
> this ends up with modprobe eth0, which will check modprobe.conf.
>
> > this message:
> > Bringing up interface eth0:  e100 device does not seem to be present, delaying e
> > th0 initialization.
> > Why??
>
> This is fedora, right? Check you kernel config, scripts and whatever is
> needed to load driver first and only then try to setup an address.
>
> --
>        Evgeniy Polyakov
>
