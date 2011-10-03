From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC patch net-next-2.6] net: introduce ethernet teaming device
Date: Mon, 3 Oct 2011 09:20:58 -0700
Message-ID: <CAEP_g=_RihjefiBcPPTjUxW7dMdey6Ufm_=yZW0y03CEXSfBoA@mail.gmail.com>
References: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
 <CAEP_g=8uJnngfKJRGLLnd8U7M9aJTfOSUheB62-O7OX6Ud0DLw@mail.gmail.com> <20111003113705.GC2140@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50347 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab1JCQVT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 12:21:19 -0400
Received: by vws1 with SMTP id 1so2908891vws.19
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2011 09:21:18 -0700 (PDT)
In-Reply-To: <20111003113705.GC2140@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 3, 2011 at 4:37 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> Sat, Oct 01, 2011 at 08:15:01PM CEST, jesse@nicira.com wrote:
>>On Fri, Sep 30, 2011 at 5:44 AM, Jiri Pirko <jpirko@redhat.com> wrote=
:
>>> This patch introduces new network device called team. It supposes t=
o be
>>> very fast, simple, userspace-driven parallel to existing bonding de=
vice.
>>> Userspace library called libteam with couple of demo apps is availa=
ble
>>> here:
>>> https://github.com/jpirko/libteam
>>> Note it's still in its dipers atm.
>>>
>>> team<->libteam use generic netlink for communication. That and rtnl
>>> suppose to be the only way to configure team device, no sysfs etc.
>>>
>>> In near future python binding for libteam will be introduced. Also
>>> daemon providing arpmon/miimon active-backup functionality will
>>> be introduced. All what's necessary is already implemented in kerne=
l team
>>> driver.
>>>
>>> Plan is to support 8023ad in near future with it's logic mainly in
>>> userspace daemon as well.
>>>
>>> Please review, try, comment. All feedback would be much appreciated=
=2E
>>>
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>>Not to push my own agenda too much but you might want to take a look
>>at Open vSwitch. =C2=A0It uses the same strategy of userspace directe=
d
>>bonding and already supports active-backup, 802.3ad, and quite a few
>>other networking tools all controlled by userspace.
>>
>>I know there's been a lot of talk and not a lot of action when it
>>comes to upstreaming but that's changing. =C2=A0We're fixing up a few=
 loose
>>ends in the userspace/kernel interface and then intend to propose a
>>patch fairly soon.
>
> Looks interesting. From quick peak the code is much bigger and fairly
> complicated. The main reason for doing "team" is to do ethernet teami=
ng
> in as much simple way as it can be done. Final user destination areas
> of openvswitch and team seem different to me.

Yes, to the end user Open vSwitch is clearly a much larger and more
complex component.  I just thought it might be of interest to you
since it already implements some of the features that you are looking
at and the kernel portion, at least, has similar goals of pushing more
logic to userspace.
