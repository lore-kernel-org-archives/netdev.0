From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sun, 15 Feb 2015 20:51:59 +0100
Message-ID: <54E0F8DF.1060602@6wind.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com> <1423901633-53789-4-git-send-email-joestringer@nicira.com> <20150214195607.GA30752@casper.infradead.org> <CANr6G5x19zc8qK0gtPBFzMD02xMxieFqGpv9-nkKyiZ1MzSUwA@mail.gmail.com> <54E0B67A.1030000@6wind.com> <CANr6G5yBW5JNMk3qvAuyD+OgtnhV6vg2E-41DO51bVtyeSWSNg@mail.gmail.com> <20150215191356.GA14888@casper.infradead.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>, Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:61039 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754889AbbBOTwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 14:52:04 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so19940723iga.5
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 11:52:02 -0800 (PST)
In-Reply-To: <20150215191356.GA14888@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/02/2015 20:13, Thomas Graf a =E9crit :
> On 02/15/15 at 11:06am, Joe Stringer wrote:
>> On 15 February 2015 at 07:08, Nicolas Dichtel <nicolas.dichtel@6wind=
=2Ecom> wrote:
>>> Le 15/02/2015 05:47, Joe Stringer a =E9crit :
>>>> Right, it was more of a general sanity check which is likely unnee=
ded.
>>>> I'm not aware of any particular case that this handles.
>>>
>>> I agree with Thomas. If we fall into this case, it's probably a rea=
l bug ;-)
>>
>> We can BUG_ON(), then.
>
> Let's do a WARN() and just error so we keep the kernel running ;-)
Yes. I wonder if there are more generic places to do this kind of check=
, because
I don't think that this kind of bug will be specific to ovs.
