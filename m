From: Jesse Gross <jesse@nicira.com>
Subject: Re: openvswitch question
Date: Wed, 19 Mar 2014 18:36:38 -0700
Message-ID: <CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:45327 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751481AbaCTBg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 21:36:59 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so171950iec.24
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 18:36:58 -0700 (PDT)
In-Reply-To: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 2:44 AM, ratheesh kannoth
<ratheesh.ksz@gmail.com> wrote:
> Hi list,
>
>
> openvswitch internal devices are not real nic. So some routine should
> receive the packet  for this interface. Who is receiving packet for
> this internal device.
> I could find a question similar floating without any answer
> http://comments.gmane.org/gmane.network.openvswitch.devel/19402

>From the perspective of the network stack, there is no difference
between Open vSwitch internal devices and real NICs so the entry
points into the stack are the same.
