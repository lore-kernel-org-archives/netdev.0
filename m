From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: sctp: convert sctp_checksum_disable
 module param into sctp sysctl
Date: Fri, 09 Aug 2013 14:50:40 -0400
Message-ID: <52053A00.80808@gmail.com>
References: <1375816693-7697-1-git-send-email-dborkman@redhat.com> <20130809.113320.681399334989952629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:48057 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030353Ab3HISuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:50:44 -0400
In-Reply-To: <20130809.113320.681399334989952629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 02:33 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue,  6 Aug 2013 21:18:12 +0200
>
>> Get rid of the last module parameter for SCTP and make this
>> configurable via sysctl for SCTP like all the rest of SCTP's
>> configuration knobs.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>
> Applied.

David

Please revert this.  This isn't a knob that that should be
so freely exposed.  I thought my response to Daniel made
that clear.

Thanks
-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
