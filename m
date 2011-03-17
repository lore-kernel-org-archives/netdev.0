From: Seblu <seblu@seblu.net>
Subject: Re: bnx2 vlan issue
Date: Fri, 18 Mar 2011 00:22:05 +0100
Message-ID: <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
 <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com> <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:43632 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755947Ab1CQXW2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 19:22:28 -0400
Received: by qwk3 with SMTP id 3so2465216qwk.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 16:22:28 -0700 (PDT)
In-Reply-To: <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 8:16 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Mar 17, 2011 at 11:02 AM, Seblu <seblu@seblu.net> wrote:
>> On Thu, Mar 17, 2011 at 3:51 PM, Seblu <seblu@seblu.net> wrote:
>
> It was a bug that it worked at all and whether it worked depended on
> the hardware/firmware/driver. =A0If an interface is attached to a
> bridge, the bridge takes all the packets received on that interface,
> including vlan packets.
ok i see.

>
> There are a few ways to setup vlans and bridging that work on all
> kernels and with all NICs:
>
> * vlans on interface, bridges contain vlan devices. =A0This gives you=
 a
> bridge for each vlan.
Except for untagged isn't it? This is why i fail. I need to have a
bridge with the untagged vlan from an interface.
Before 2.6.37 (with most of drivers/firmware/hardware i use) when a
vlan is defined on an interface, for example eth0, eth0.15 show vlan15
frames and eth0 show untagged frames.

I've tryed eth0.0, expecting to have untagged vlan, but this doesnt wor=
k.
How can I create a bridge with the untagged vlan from an interface?

> * bridge on interface, vlans on bridge device. =A0This gives you a
> bridge with all packets and vlan devices can give you specific vlans.
I cannot use this schema, i used bridge to bring together vnet
interface and vlan interface.

> * Use ebtables rules in the bridge to accept/reject certain packets a=
s desired.
I don't see how use ebtables to push untagged frame to a dedicated
iface which can be added in a bridge.

--=20
S=E9bastien Luttringer
www.seblu.net
