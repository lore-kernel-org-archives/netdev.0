From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 1/3] net: add skb_checksum_setup
Date: Mon, 13 Jan 2014 14:40:13 +0100
Message-ID: <52D3ECBD.7050203@6wind.com>
References: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com> <1389261768-30606-2-git-send-email-paul.durrant@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD0204A79@AMSPEX01CL01.citrite.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:56563 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbaAMNkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:40:17 -0500
Received: by mail-wg0-f43.google.com with SMTP id k14so6632876wgh.10
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 05:40:15 -0800 (PST)
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0204A79@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/01/2014 12:26, Paul Durrant a =E9crit :
>> -----Original Message-----
>> From: Paul Durrant [mailto:paul.durrant@citrix.com]
>> Sent: 09 January 2014 10:03
>> To: netdev@vger.kernel.org; xen-devel@lists.xen.org
>> Cc: Paul Durrant; David Miller; Eric Dumazet; Veaceslav Falico; Alex=
ander
>> Duyck; Nicolas Dichtel
>> Subject: [PATCH net-next v2 1/3] net: add skb_checksum_setup
>>
>> This patch adds a function to set up the partial checksum offset for=
 IP
>> packets (and optionally re-calculate the pseudo-header checksum) int=
o the
>> core network code.
>> The implementation was previously private and duplicated between xen=
-
>> netback
>> and xen-netfront, however it is not xen-specific and is potentially =
useful
>> to any network driver.
>>
>> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
>> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Ping?
Your patch is under review by David (see
http://patchwork.ozlabs.org/patch/308539/), please be patient ;-)


Nicolas
