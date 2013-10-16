From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 net] {xfrm, sctp} Stick to software crc32 even if hardware
 is capable of that
Date: Wed, 16 Oct 2013 09:58:03 +0800
Message-ID: <525DF2AB.1050806@windriver.com>
References: <1381828777-15894-1-git-send-email-fan.du@windriver.com> <525DE666.10308@gmail.com> <525DF141.6060302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nhorman@tuxdriver.com>, <steffen.klassert@secunet.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44468 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932759Ab3JPCAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 22:00:10 -0400
In-Reply-To: <525DF141.6060302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8816=E6=97=A5 09:52, Vlad Yasevich wrote:
> On 10/15/2013 09:05 PM, Vlad Yasevich wrote:
>> On 10/15/2013 05:19 AM, Fan Du wrote:
>>> igb/ixgbe have hardware sctp checksum support, when this feature is
>>> enabled
>>> and also IPsec is armed to protect sctp traffic, ugly things happen=
ed as
>>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum
>>> every thing
>>> up and pack the 16bits result in the checksum field). The result is=
 fail
>>> establishment of sctp communication.
>>>
>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
>>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>>
>> Looks good to me.
>>
>
> Just tryied applying this and looks like you based this on net-next.
> This fixes a rather ugly bug when checksum offloading is done.
> I am going to rebase this and re-submit for net.

:( Sorry for the inconvenience. Stable tree might hurts also.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
