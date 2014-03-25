From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: openvswitch question
Date: Tue, 25 Mar 2014 10:43:59 +0100
Message-ID: <53314FDF.2060205@6wind.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>	<CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>	<532C0B76.4020108@6wind.com> <CAGZFCEFZgjStq7kH2pfi+X-sjJU69v7zXWey6JztWH1Y-XoXYQ@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:61860 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbaCYJoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 05:44:08 -0400
Received: by mail-bk0-f48.google.com with SMTP id mx12so79218bkb.21
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 02:44:07 -0700 (PDT)
In-Reply-To: <CAGZFCEFZgjStq7kH2pfi+X-sjJU69v7zXWey6JztWH1Y-XoXYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/03/2014 16:15, ratheesh kannoth a =E9crit :
> On Fri, Mar 21, 2014 at 3:20 PM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> Stop me if I'm wrong, but there may be a difference with netns, the
>> netdevice
>> can be in a different netns than the ovs port.
>
> No.  below command show  no name space.
>
> ip netns list

Sure, you have to create one first.
But you can start ovs in the current netns and move the interface to an=
other
netns after that.
Then, you will show the ovs port in the initial netns and the network d=
ev in the
other netns.
