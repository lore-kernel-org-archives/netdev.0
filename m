From: yao zhao <yao.development@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 09:57:51 -0500
Message-ID: <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	<1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	<1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:45316 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932088Ab2BAO5w convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 09:57:52 -0500
Received: by obcva7 with SMTP id va7so1391994obc.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 06:57:52 -0800 (PST)
In-Reply-To: <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2012 at 9:50 AM, yao zhao <yao.development@gmail.com> wr=
ote:
>
>
> On Wed, Feb 1, 2012 at 8:04 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>>
>> Le mercredi 01 f=E9vrier 2012 =E0 11:24 +0000, Leonardo Uzcudun a =E9=
crit :
>> > ________________________________
>> > Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
>> > A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>> > Inviato: Mercoled=EC 1 Febbraio 2012 12:22
>> > Oggetto: VLAN 1 - Native
>> >
>> > Hello:
>> >
>> > I'm connecting my Linux computer (debian 2.6.32-5) to a switch to
>> > implement vlans.
>> >
>> > All is working fine except for the VLAN 1. Of sure you are aware o=
f
>> > this situation and i would like to knoe if there is any parameter =
or
>> > setting that i should set in the vlan (linux side, not switch)
>> > configuration. Here's my configuration:
>> > ip addr add 0.0.0.0 dev eth0
>> > ip link set eth0 up
>> > ip link add link eth0 name eth0.1 type vlan id 1
>> > ip link add link eth0 name eth0.101 type vlan id 101
>> > ip addr add 0.0.0.0 dev eth0.1
>> > ip addr add 0.0.0.0 dev eth0.101
>> > ip link set eth0.101 up
>> > ip link set eth0.1 up
>> > brctl addbr br_vlan_1
>> > brctl addbr br_vlan_101
>> > brctl addif br_vlan_1 eth0.1
>> > brctl addif br_vlan_101 eth0.101
>> > ip addr add 0.0.0.0 dev br_vlan_1
>> > ip
>> > addr add 0.0.0.0 dev br_vlan_101
>> > ip link set br_vlan_1 up
>> > ip link set br_vlan_101 up
>> >
>> > Traffic on vlan 101 is working fine. Traffic on VLAN 1 is not work=
ing
>> > cause the packets are going out from eth0 like tagged. How could i=
 set
>> > the VID 1 as untagged?
>>
>> What do you mean by "sending packets for VID 1, untagged " ?
>>
 on switch like Cisco: vlan 1 is the native vlan or default vlan so it =
is
 untagged. untagged means packet has no vlan header.

>>
>> What is the difference between vlan 101 and vlan 1 ?

 No other difference. Just because it is vlan 1=A0 which is special in
 switches(of course it can be changed on switch side but he doesn't wan=
t to)
>>
>>
>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
