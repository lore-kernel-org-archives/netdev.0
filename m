From: Krzysztof Kolasa <kkolasa@winsoft.pl>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Wed, 15 Oct 2014 22:20:05 +0200
Message-ID: <543ED6F5.4080901@winsoft.pl>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>	 <20141014.164705.1874094084240216813.davem@davemloft.net>	 <CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>	 <20141014.171559.1355616486999711590.davem@davemloft.net>	 <CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>	 <1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>	 <543E4DD8.80203@winsoft.pl>	 <1413372422.17365.10.camel@edumazet-glaptop2.roam.corp.google.com>	 <543E5D1F.2020207@winsoft.pl> <1413387152.17365.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps01.winsoft.pl ([5.133.9.51]:43677 "EHLO vps01.winsoft.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbaJOUUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 16:20:11 -0400
In-Reply-To: <1413387152.17365.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 15.10.2014 o 17:32, Eric Dumazet pisze:
> On Wed, 2014-10-15 at 13:40 +0200, Krzysztof Kolasa wrote:
>
>> on a 32bit system, the patch did not solve the problem :(
>> I have exactly the same problem as before the patch
>
> You mean Cong patch ?
Yes
>
>> I do not understand this, perhaps the problem is hidden somewhere else,
>> one thing is certain after revert commit 971f10eca1 everything works
>> correctly
>>
> Can you privately send me the vmlinux file ?
>
> It might be a compiler issue...
>
>
>
I sent the file
