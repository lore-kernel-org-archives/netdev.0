From: Krzysztof Kolasa <kkolasa@winsoft.pl>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Wed, 15 Oct 2014 22:42:23 +0200
Message-ID: <543EDC2F.1090604@winsoft.pl>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>	<20141014.164705.1874094084240216813.davem@davemloft.net>	<CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>	<20141014.171559.1355616486999711590.davem@davemloft.net>	<CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>	<1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>	<543E4DD8.80203@winsoft.pl> <CAHA+R7OEvTcZOm-OepWYvGP+pC_CJRoSen351nw8VJGdLTo0uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps01.winsoft.pl ([5.133.9.51]:47812 "EHLO vps01.winsoft.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbaJOUm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 16:42:29 -0400
In-Reply-To: <CAHA+R7OEvTcZOm-OepWYvGP+pC_CJRoSen351nw8VJGdLTo0uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 15.10.2014 o 22:36, Cong Wang pisze:
> On Wed, Oct 15, 2014 at 3:35 AM, Krzysztof Kolasa <kkolasa@winsoft.pl> wrote:
>> one-line patch not resolve problem, fix created by Cong Wang resolves
>> problem !!!
>>
>> tested on 64bit system and working OK
>>
> So my patch fixes your problem on 64bit but not on 32bit,
> is this correct?
Yes
