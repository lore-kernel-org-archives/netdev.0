From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: openvswitch question
Date: Fri, 21 Mar 2014 10:50:46 +0100
Message-ID: <532C0B76.4020108@6wind.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com> <CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>,
	ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43349 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaCUJut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 05:50:49 -0400
Received: by mail-we0-f174.google.com with SMTP id t60so1398425wes.19
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 02:50:48 -0700 (PDT)
In-Reply-To: <CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/03/2014 02:36, Jesse Gross a =C3=A9crit :
> On Wed, Mar 19, 2014 at 2:44 AM, ratheesh kannoth
> <ratheesh.ksz@gmail.com> wrote:
>> Hi list,
>>
>>
>> openvswitch internal devices are not real nic. So some routine shoul=
d
>> receive the packet  for this interface. Who is receiving packet for
>> this internal device.
>> I could find a question similar floating without any answer
>> http://comments.gmane.org/gmane.network.openvswitch.devel/19402
>
>  From the perspective of the network stack, there is no difference
> between Open vSwitch internal devices and real NICs so the entry
> points into the stack are the same.

Stop me if I'm wrong, but there may be a difference with netns, the net=
device
can be in a different netns than the ovs port.
