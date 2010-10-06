From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/3] bonding: rejoin multicast groups on VLANs
Date: Wed, 6 Oct 2010 08:12:25 -0400
Message-ID: <-8922483842967465750@unknownmsgid>
References: <20101005220757.GB19931@redhat.com> <1286324639-22314-1-git-send-email-fleitner@redhat.com>
 <20101005.202840.183059128.davem@davemloft.net>
Mime-Version: 1.0 (iPhone Mail 8B117)
Content-Type: text/plain; charset=ISO-8859-1
Cc: "fleitner@redhat.com" <fleitner@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37289 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab0JFMMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 08:12:30 -0400
Received: by fxm4 with SMTP id 4so1060737fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 05:12:28 -0700 (PDT)
In-Reply-To: <20101005.202840.183059128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct 5, 2010, at 11:28 PM, David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fleitner@redhat.com>
> Date: Tue,  5 Oct 2010 21:23:57 -0300
>
>> During a failover, the IGMP membership is sent to update
>> the switch restoring the traffic, but it misses groups added
>> to VLAN devices running on top of bonding devices.
>>
>> This patch changes it to iterate over all VLAN devices
>> on top of it sending IGMP memberships too.
>>
>> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
>
> This seems to address Andy's feedback properly, and otherwise
> looks good to me, so applied to net-next-2.6

Agreed. Thanks for making those changes, Flavio.
