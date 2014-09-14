From: Kalle Valo <kvalo@adurom.com>
Subject: Re: iwlwifi no authentication with AP - Re: pull request: wireless-next 2014-09-08
Date: Sun, 14 Sep 2014 21:08:36 +0300
Message-ID: <877g162hy3.fsf@purkki.adurom.net>
References: <20140908191630.GB29412@tuxdriver.com>
	<540F5927.7000306@hartkopp.net>
	<CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg@mail.gmail.com>
	<540F61D0.9000704@hartkopp.net>
	<CAMw6YJLeO1JZeY6hNe-TXOS56b-otk+htt5VPPor+9iYCQz53Q@mail.gmail.com>
	<540FDB3C.6060301@hartkopp.net>
	<CANUX_P3kOetqEneHgqoCDN4c85SQYD-G=mQj_o1c_TvKmE5psA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Vadim Kochan <vadim4j@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from purkki.adurom.net ([80.68.90.206]:50716 "EHLO purkki.adurom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbaINSIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Sep 2014 14:08:40 -0400
In-Reply-To: <CANUX_P3kOetqEneHgqoCDN4c85SQYD-G=mQj_o1c_TvKmE5psA@mail.gmail.com>
	(Emmanuel Grumbach's message of "Wed, 10 Sep 2014 11:24:01 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emmanuel Grumbach <egrumbach@gmail.com> writes:

> On Wed, Sep 10, 2014 at 8:01 AM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>> On 10.09.2014 00:07, Vadim Kochan wrote:
>>> I have the same issue with iwlwifi.
>>
>> I tried an old zd1211 wireless USB stick to check if this problem is 80211
>> related. But the USB stick works fine (I'm using it right now).
>> So its definitely looks like an iwlwifi issue.
>>
>>> iwlwifi 0000:02:00.0: fail to flush all tx fifo queues Q 0
>>
>> Wasn't there any change in the iwlwifi tx path recently??
>
> Can you please try the patch attached? It works for me.

Upgraded to latest wireless-testing and iwldvm was broken. This patch
fixed it for me as well.

Could we have the fix in the wireless tree ASAP? Not really fun to find
out that the driver is completely broken.

-- 
Kalle Valo
