From: Tomas Carnecky <tom@dbservice.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in ip_fragment
Date: Wed, 27 Apr 2011 09:22:53 +0200
Message-ID: <4DB7C44D.60306@dbservice.com>
References: <20110426203154.GM15903@stratus.com>	 <20110426.134637.48491363.davem@davemloft.net>	 <1303851185.2699.7.camel@edumazet-laptop>	 <20110426205901.GN15903@stratus.com>	 <1303851718.2699.8.camel@edumazet-laptop>	 <20110426211946.GO15903@stratus.com> <1303853047.2699.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from office.neopsis.com ([78.46.209.98]:58887 "EHLO
	office.neopsis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab1D0HxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 03:53:14 -0400
In-Reply-To: <1303853047.2699.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/11 11:24 PM, Eric Dumazet wrote:
> Le mardi 26 avril 2011 =C3=A0 17:19 -0400, Bandan Das a =C3=A9crit :
>> Yeah, I just rechecked and this is already in Linus' tree. So, Tomas=
 you can
>> either try pulling in those changes or you can apply this patch and =
see
>> if it makes any difference. Thanks!
> Better pull Linus tree because there is another patch involved.
>
> (commits c65353daf137dd41f3ede3baf62d561fca076228
> ip: ip_options_compile() resilient to NULL skb route

Still getting that error (on rc4-00245-g4175242, which includes that=20
commit).

