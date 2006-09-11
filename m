From: VinX <vincenx@fastwebnet.it>
Subject: Re: tiacx module fail
Date: Mon, 11 Sep 2006 23:05:26 +0200
Message-ID: <4505CF96.4060602@fastwebnet.it>
References: <4503F640.3040300@fastwebnet.it> <20060911122541.GA4537@kiopa.cmartin.tk> <450560F6.5030405@fastwebnet.it> <20060911200343.GA3878@kiopa.cmartin.tk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa002msr.fastwebnet.it ([85.18.95.65]:48104 "EHLO
	aa002msr.fastwebnet.it") by vger.kernel.org with ESMTP
	id S964797AbWIKUqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 16:46:31 -0400
Received: from theconfessional.redirectme.net (23.251.157.101) by aa002msr.fastwebnet.it (7.2.070.1)
        id 44ECD14E009FB52A for netdev@vger.kernel.org; Mon, 11 Sep 2006 22:46:29 +0200
Received: from [192.168.1.144] (unknown [192.168.0.50])
	by theconfessional.redirectme.net (Postfix) with ESMTP id 7745B38E663
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 22:43:27 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060911200343.GA3878@kiopa.cmartin.tk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carlos Mart=EDnn Nieto wrote:
>  Did you bring the interface up (ifconfig eth1 up)? It won't work
> before that because parts of the card haven't been initialised.
ok, now it seems to work!

> IIRC, the tiacx module in wireless-2.6 uses softmac and we never
> managed to get it working properly. There is a version with the
> devicescape stack which seems to work, though it might take a bit of
> hunting down.
ah ok, but why doesn't work it with acx module?
if i use a kernel <=3D 2.6.16, it works fine...
uhm... in the lastest kernels there are some changes that they are
indipendent on a generic wireless module, is it correct?

Thanks
VinX
