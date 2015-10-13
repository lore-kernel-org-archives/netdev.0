From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V15 0/3] openvswitch: Add support for 802.1ad
Date: Mon, 12 Oct 2015 23:48:22 -0700
Message-ID: <CALnjE+qd8zsontA+1uvSGiOz6p5YZsX1YmJTKhVoaE+yrodOqA@mail.gmail.com>
References: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
	<20151012.195841.292062617131376194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas F Herbert <thomasfherbert@gmail.com>,
	netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36560 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbJMGsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:48:22 -0400
Received: by ignr19 with SMTP id r19so29885398ign.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:48:22 -0700 (PDT)
In-Reply-To: <20151012.195841.292062617131376194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 7:58 PM, David Miller <davem@davemloft.net> wrote:
> From: Thomas F Herbert <thomasfherbert@gmail.com>
> Date: Sat, 10 Oct 2015 19:40:30 -0400
>
>> Thomas F Herbert (3):
>>   openvswitch: 802.1ad uapi changes.
>>   Check for vlan ethernet types for 8021.q or 802.1ad
>>   802.1AD: Flow handling, actions, vlan parsing and netlink attributes
>
> I think this patch series has gone long enough, can I get some ACK's
> ASAP for this V15 posting?
>
I know this is taking bit long but this patch-set is touching one of
most complex netlink attributes processing code in OVS. I think we are
very close to final version. As of now I am seeing couple of bugs, one
of the bug is newly introduced in this version. And there is still
code duplication in flow extract. So I can not ack the patch yet.
Sorry for the delay.
