From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: Re: openvswitch question
Date: Fri, 28 Mar 2014 09:24:27 +0530
Message-ID: <CAGZFCEFQ0ptVarxUi9-+uptvMFNnD29DYLLS3JB+Y0mwOsThoA@mail.gmail.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
	<CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
	<532C0B76.4020108@6wind.com>
	<CAGZFCEFZgjStq7kH2pfi+X-sjJU69v7zXWey6JztWH1Y-XoXYQ@mail.gmail.com>
	<53314FDF.2060205@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:52689 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaC1Dy2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 23:54:28 -0400
Received: by mail-yk0-f171.google.com with SMTP id q9so3179138ykb.16
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 20:54:27 -0700 (PDT)
In-Reply-To: <53314FDF.2060205@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 3:13 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 21/03/2014 16:15, ratheesh kannoth a =E9crit :
>
>> On Fri, Mar 21, 2014 at 3:20 PM, Nicolas Dichtel
>> <nicolas.dichtel@6wind.com> wrote:
>>>
>>> Stop me if I'm wrong, but there may be a difference with netns, the
>>> netdevice
>>> can be in a different netns than the ovs port.

Nicolas,

You are absolutely right.  Thanks a lot. This is only available in
newer version of  openvswitch.

I was working in 2.0.0. I could see the internal device ( switch )
device  using command  "ifconfig".

Yesterday  i git cloned newest version. when i created a new internal
device ( openvswitch switch ),  ifconfig command doesnot list out the
device. http://lists.linuxfoundation.org/pipermail/containers/2007-Sept=
ember/007112.html

-Ratheesh
