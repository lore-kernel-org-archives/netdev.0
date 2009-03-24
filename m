From: Richard Zhao <linuxzsc@gmail.com>
Subject: Re: [PATCH 3/3] smsc911x: add flag SMSC911X_USE_INTERPHY
Date: Tue, 24 Mar 2009 16:36:08 +0800
Message-ID: <4e090d470903240136y1b553b10gda626b3a9bb661f5@mail.gmail.com>
References: <4e090d470903232347g2b6e91a7o385af2e66f05a936@mail.gmail.com>
	 <20090324075105.GE25436@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Richard Zhao <linuxzsc@gmail.com>, steve.glendinning@smsc.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:46013 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbZCXIgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 04:36:12 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2195302rvb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2009 01:36:08 -0700 (PDT)
In-Reply-To: <20090324075105.GE25436@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 3:51 PM, Sascha Hauer <s.hauer@pengutronix.de> wrote:
> Hi Richard,
>
> On Tue, Mar 24, 2009 at 02:47:25PM +0800, Richard Zhao wrote:
>> mx31pdk board don't have external PHY, but it wrongly pull up MDIO.
>> So, add flag SMSC911X_USE_INTERPHY to force using internal PHY.
>
> This patch is outdated. Linux-next already contains a
> SMSC911X_FORCE_INTERNAL_PHY for exactly this reason.
>
> Sascha
>
Hi Sascha,

Sorry I didn't check linux-next. Do I need always to create mxc
patches based on linux-nex?
And I don't know why the smsc911x patch commited on Feb 1 on
linux-next still not be merged to mainline?

Thanks
Richard
