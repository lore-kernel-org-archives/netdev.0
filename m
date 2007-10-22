From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: about multiple network interface
Date: Mon, 22 Oct 2007 13:14:10 +0400
Message-ID: <20071022091410.GB12186@2ka.mipt.ru>
References: <105610bf0710180606w6a687642r35414d2b66b6d3af@mail.gmail.com> <20071018132836.GA15906@2ka.mipt.ru> <105610bf0710211909r6ab2b63fo8a4f67eba6c05bc7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: wit <is01kzh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58745 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbXJVJOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 05:14:14 -0400
Content-Disposition: inline
In-Reply-To: <105610bf0710211909r6ab2b63fo8a4f67eba6c05bc7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 10:09:38AM +0800, wit (is01kzh@gmail.com) wrote:
> But this does work until I add a ifcfg-eth0 in
> sysconfig/network-script with the following content:
> DEVICE=eth0
> ONBOOT=yes
> 
> What is the relationship between these two files? And sometimes, I see

It depends on your distro - when script calls "modprobe $DEVICE"
this ends up with modprobe eth0, which will check modprobe.conf.

> this message:
> Bringing up interface eth0:  e100 device does not seem to be present, delaying e
> th0 initialization.
> Why??

This is fedora, right? Check you kernel config, scripts and whatever is
needed to load driver first and only then try to setup an address.

-- 
	Evgeniy Polyakov
