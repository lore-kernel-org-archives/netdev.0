From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Mon, 28 Apr 2014 12:29:01 -0700
Message-ID: <CA+mtBx-umd3vmNggurFiugQXr_gb+14HvHo=jdaPnpC4cL=tdA@mail.gmail.com>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
	<535E99F3.3050404@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:48445 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932972AbaD1T3D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:29:03 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so5213417igc.1
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 12:29:01 -0700 (PDT)
In-Reply-To: <535E99F3.3050404@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 11:12 AM, Florent Fourcot
<florent.fourcot@enst-bretagne.fr> wrote:
> Le 27/04/2014 01:00, Tom Herbert a =C3=A9crit :
>>       net->ipv6.sysctl.flowlabel_consistency =3D 1;
>> +     net->ipv6.sysctl.auto_flowlabels =3D 1;
>
> I do not like setting this option to one by default. The idea of
> flowlabel_consistency above was to be sure that all labels given by t=
he
> host are in the control of the flow label manager.
>
> By enabling auto_flowlabels, we can have conflict between the flow la=
bel
> manager policy, and a randomly generated label.
>
What would be the consequences of such a conflict? Per RFC6437
stateless and stateful flow labels are selected from the same space,
the probability of collision between them is assumed to be non-zero.
We obviously can't make any assumptions on RX.

Thanks,
Tom

> And I do not have a strong opinion on it, but perhaps should
> auto_flowlabels depends of a disabled flowlabel_consistency, to have =
a
> coherent behaviour for users.
>
> Regards,
>
> Florent.
