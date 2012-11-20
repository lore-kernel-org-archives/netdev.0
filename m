From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RESEND PATCH net-next 1/1] sit: allow to configure 6rd tunnels
 via netlink
Date: Tue, 20 Nov 2012 18:22:52 +0100
Message-ID: <50ABBC6C.6020103@6wind.com>
References: <20121120.033405.490869980095149376.davem@davemloft.net> <1353400905-28335-1-git-send-email-nicolas.dichtel@6wind.com> <20121120090113.47ce16b5@nehalam.linuxnetplumber.net> <50ABB9CD.6080506@6wind.com> <20121120091748.359d95db@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62423 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab2KTRW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 12:22:57 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2555391bkw.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 09:22:55 -0800 (PST)
In-Reply-To: <20121120091748.359d95db@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/11/2012 18:17, Stephen Hemminger a =E9crit :
> On Tue, 20 Nov 2012 18:11:41 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Le 20/11/2012 18:01, Stephen Hemminger a =E9crit :
>>> On Tue, 20 Nov 2012 09:41:45 +0100
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>>
>>>> This patch add the support of 6RD tunnels management via netlink.
>>>> Note that netdev_state_change() is now called when 6RD parameters =
are updated.
>>>>
>>>> 6RD parameters are updated only if there is at least one 6RD attri=
bute.
>>>>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>> ---
>>>>    include/uapi/linux/if_tunnel.h |   4 ++
>>>>    net/ipv6/sit.c                 | 149 ++++++++++++++++++++++++++=
++++++++-------
>>>>    2 files changed, 128 insertions(+), 25 deletions(-)
>>>>
>>>
>>> Ok, but iproute2 git is currently for 3.6
>>> Please resubmit when 3.7 is finished during 3.8 merge window.
>> Hmm, not sure to understand. This is a kernel patch.
>
>
> I assumed you would need a user space part as well.
>
Oh yes. And I was waiting the proper time to send patches, like for net=
conf ;-)
