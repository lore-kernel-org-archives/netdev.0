From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: Improve handling of IPv6 packets
Date: Thu, 26 Feb 2015 10:05:22 -0600
Message-ID: <54EF4442.8020006@lwfinger.net>
References: <1424791381-31863-1-git-send-email-Larry.Finger@lwfinger.net> <87zj80de63.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stable <stable@vger.kernel.org>, Alan Fisher <acf@unixcube.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:39861 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbbBZQFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:05:25 -0500
In-Reply-To: <87zj80de63.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 06:56 AM, Kalle Valo wrote:
> Larry Finger <Larry.Finger@lwfinger.net> writes:
>
>> Routine rtl_is_special_data() is supposed to identify packets that need to
>> use a low bit rate so that the probability of successful transmission is
>> high. The current version has a bug that causes all IPv6 packets to be
>> labelled as special, with a corresponding low rate of transmission. A
>> complete fix will be quite intrusive, but until that is available, all
>> IPv6 packets are identified as regular.
>>
>> This patch also removes a magic number.
>>
>> Reported-and-tested-by: Alan Fisher <acf@unixcube.org>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: Stable <stable@vger.kernel.org> [3.18+]
>> Cc: Alan Fisher <acf@unixcube.org>
>
> Should this go to 4.0?

Yes. I should have indicated that in the subject.

My expectation is that any patch that has a Cc for Stable should be applied as 
soon as possible.

Larry
