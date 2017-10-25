From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: linux kernel =?utf-8?B?4oCTIDQuNC40?= =?utf-8?Q?5?= : VPN test
 failure
Date: Wed, 25 Oct 2017 15:08:30 +0200
Message-ID: <20171025130830.GA4869@kroah.com>
References: <5fae6d9bd62e42acb24a7a8cfdcc8a86@HIBDWSMB01.ad.harman.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "amit.pundir@linaro.org" <amit.pundir@linaro.org>,
        "lorenzo@google.com" <lorenzo@google.com>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
        "g.nault@alphalink.fr" <g.nault@alphalink.fr>,
        "jiri@mellanox.com" <jiri@mellanox.com>
To: "Nanjappa, Gangadhar" <Gangadhar.Nanjappa@harman.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:49324 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbdJYNIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 09:08:22 -0400
Content-Disposition: inline
In-Reply-To: <5fae6d9bd62e42acb24a7a8cfdcc8a86@HIBDWSMB01.ad.harman.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 12:49:09PM +0000, Nanjappa, Gangadhar wrote:
> Hi All,
> Using linux kernel – 4.4.45 (Blurry Fish Butt), VPN test fails. If I
> revert the attached five patches, VPN test passes. But I’m not
> supposed to revert the patches to get the test passed. I’m analyzing
> the patches, please help me to resolve this issue. If the below
> patches are present, in the VpnTest.java file that I’ve attached, the
> failure path is testAppDisallowed()--> checkNoTrafficOnVpn() -->
> checkUdpEcho("192.0.2.251", null) --> fail("Received unexpected
> reply");

4.4.45 is _very_ old, can you duplicate this on 4.4.94?  Do you also
have this problem on 4.14-rc6?

thanks,

greg k-h
