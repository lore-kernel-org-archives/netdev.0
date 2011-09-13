From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCHv2] ipv6: Create module parameter for use_tempaddr
Date: Tue, 13 Sep 2011 20:39:24 +0200
Message-ID: <87r53ks2w3.fsf@nemi.mork.no>
References: <4E6E62D1.8010108@hp.com>
	<20110912212011.7C65B2041D@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46391 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216Ab1IMSuX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 14:50:23 -0400
In-Reply-To: <20110912212011.7C65B2041D@glenhelen.mtv.corp.google.com> (Paul
	Stewart's message of "Wed, 31 Aug 2011 23:03:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Stewart <pstew@chromium.org> writes:

> When ipv6 is used as a module, there is no good place to set
> the default value for use_tempaddr.  Using sysctl.conf will
> set this parameter too early -- before the module is loaded.
> To solve this, create a module parameter that will set the
> default value of use_tempaddr for all devices.

How is use_tempaddr any different from the other /proc/sys/net/ipv6/*
variables?  Do you want to add a module parameter for all of them?

Why can't you run sysctl with an ipv6-specific sysctl.conf at a time
fitting your boot sequence?  Or load the ipv6 module before sysctl is
loads the default sysctl.conf if that is what you want?  Or just set th=
e
variables in your network configuration scripts, prior to bringing the
interfaces up?

Or do as most people do nowadays:  Forget that ipv6 can be built as a
module, and just use it builtin.  It's not like it can be unloaded
anyway, so building it as a module does not give you anything.


Bj=C3=B8rn
