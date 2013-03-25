From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bridge: avoid br_ifinfo_notify when nothing
 changed
Date: Mon, 25 Mar 2013 19:32:14 +0400
Message-ID: <51506DFE.4040405@cogentembedded.com>
References: <1364015653-7322-1-git-send-email-honkiko@gmail.com> <1364131607-11698-1-git-send-email-honkiko@gmail.com> <514F0F07.9050702@cogentembedded.com> <20130324.171537.1255124338630598287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: honkiko@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	herbert@gondor.hengli.com.au, zhiguo.hong@emc.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:46627 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757479Ab3CYPdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 11:33:13 -0400
Received: by mail-la0-f45.google.com with SMTP id er20so11499779lab.4
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 08:33:11 -0700 (PDT)
In-Reply-To: <20130324.171537.1255124338630598287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-03-2013 1:15, David Miller wrote:

>>> When neither IFF_BRIDGE nor IFF_BRIDGE_PORT is set,
>>> and afspec == NULL but  protinfo != NULL, we run into
>>> "if (err == 0) br_ifinfo_notify(RTM_NEWLINK, p);" with
>>> random value in ret.

>>> Thanks to Sergei for pointing out the error in commit comments.

>>> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

>>      For the future, if you post the revised version of the patch, you
>> should indicate in the subject it like this: [PATCH v2].

> I'm disappointed that you have enough energy to point out such a lower
> priority omission, but you lack the time for something more important,
> which is giving this patch your explicit ACK if it fixes all of the
> issues you pointed out to him.

    Sorry, I don't usuallly ACK patches in an area I'm not closely familiar 
with. Though I can add:

Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei
