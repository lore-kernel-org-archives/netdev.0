From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] sctp: user perfect name for Delayed SACK Timer option
Date: Wed, 19 Jan 2011 16:22:52 +0800
Message-ID: <4D369F5C.80901@cn.fujitsu.com>
References: <4D3693CA.40508@cn.fujitsu.com> <20110118.233932.91327830.davem@davemloft.net> <4D369E03.2000109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54494 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753643Ab1ASIXS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 03:23:18 -0500
In-Reply-To: <4D369E03.2000109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> David Miller wrote, at 01/19/2011 03:39 PM:
>> From: Shan Wei <shanwei@cn.fujitsu.com>
>> Date: Wed, 19 Jan 2011 15:33:30 +0800
>>
>>> The option name of Delayed SACK Timer should be SCTP_DELAYED_SACK,
>>> not SCTP_DELAYED_ACK.
>>>
>>> Reference:
>>> 8.1.19.  Get or Set Delayed SACK Timer (SCTP_DELAYED_SACK)
>>> =EF=BC=88http://tools.ietf.org/html/draft-ietf-tsvwg-sctpsocket-25)
>>>
>>>
>>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>> You can't make this change, you'll break applications using the
>> existing definition.
> No documents guide user to use SCTP_DELAYED_ACK option.
> I double that there is no applications using this option.
>
> If, there be. How about keeping this be concomitant with SCTP_DELAYED=
_SACK?

You sould do as the same as the following patch, which has fixed the sa=
me
problem of lksctp-tools, but not lksctp:

http://git.kernel.org/?p=3Dlinux/kernel/git/vxy/lksctp-tools.git;a=3Dco=
mmit;h=3Decdc6c0d3c3e40843916427923a45a93d748c1c6



