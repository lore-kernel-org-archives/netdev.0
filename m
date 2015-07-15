From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: forward packets to CPU when a port
 in promiscuous mode
Date: Wed, 15 Jul 2015 00:18:20 -0700
Message-ID: <CAE4R7bAy4WKaScamnJJR-bQR4n+=sqKBoR7B=saXCY989+2+3A@mail.gmail.com>
References: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bChu5sAKpU5tUkENfWZMhaWSs3EQZeggUxR=BjKSOqOeg@mail.gmail.com>
 <20150715044521.GA7603@vergenet.net> <CAE4R7bBH3dTfivKqo9qzRVhtpUiDzGdDmoeceY5YBq6A3VR03g@mail.gmail.com>
 <20150715063453.GB7603@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:34199 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbbGOHSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 03:18:40 -0400
Received: by obre1 with SMTP id e1so21072451obr.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 00:18:39 -0700 (PDT)
In-Reply-To: <20150715063453.GB7603@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 11:34 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> On Tue, Jul 14, 2015 at 10:32:54PM -0700, Scott Feldman wrote:

>> > @@ -5263,11 +5301,16 @@ static int rocker_port_master_changed(struct net_device *dev)
>> >          * 3. Other, e.g. being added to or removed from a bond or openvswitch,
>> >          *    in which case nothing is done
>> >          */
>>
>> Maybe comment above needs adjusting?
>
> Indeed, sorry for missing that.
> How about this?
>
>
>         /* There are currently five cases handled here:
>          * 1. Joining a bridge
>          * 2. Joining a Open vSwitch datapath
>          * 3. Leaving a previously joined bridge
>          * 4. Leaving a previously joined Open vSwitch datapath
>          * 5. Other, e.g. being added to or removed from a bond,
>          *    in which case nothing is done
>          */

Seems like one of those comments that needs adjusting each time the
code changes, which isn't good.  Maybe just kill the comment or write
in a generic way saying what code is doing.  Code seems obvious enough
to me to not require a comment.
