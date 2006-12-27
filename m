From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for
 mobility header.
Date: Wed, 27 Dec 2006 14:44:52 +0900 (JST)
Message-ID: <20061227.144452.1044954245.takamiya@po.ntts.co.jp>
References: <20061210.225055.45514229.davem@davemloft.net>
	<20061227.111429.51867516.yoshfuji@linux-ipv6.org>
	<4591FD33.3070205@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:36615 "EHLO
	mail2.ics.ntts.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932915AbWL0F46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 00:56:58 -0500
To: nakam@linux-ipv6.org
In-Reply-To: <4591FD33.3070205@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Wed, 27 Dec 2006 13:57:23 +0900
>> [Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for mobility header.] 
>> Masahide NAKAMURA <nakam@linux-ipv6.org> wrote....

> > Anyway, we have 4 options.
> > 
> > 1. IPV6_CHECKSUM default for IPPROTO_MH == 4
> >    omit checksumming in mip6_mh_filter()
> > 2. IPV6_CHECKSUM default for IPPROTO_MH == -1
> >    omit checksumming in mip6_mh_filter()
> > 3. IPV6_CHECKSUM for IPPROTO_MH == 4
> >    always perform checksumming in mip6_mh_filter()
> > 4. IPV6_CHECKSUM default for IPPROTO_MH == -1
> >    always perform checksumming in mip6_mh_filter()
> > 
> > Current behavior is 4, but it is not appropriate.
> > I guess 1 is the way to go.
> 
> I would like to have 1, too.

  I think 1. is suitable.

--
Noriaki TAKAMIYA
