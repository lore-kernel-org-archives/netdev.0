From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: How to hairpin two Ethernet interfaces together (L2 hub/repeater
 mode)?
Date: Mon, 25 Feb 2013 14:16:53 -0500
Message-ID: <512BB8A5.60103@mojatatu.com>
References: <CAKuTDr_eC4Wrv=uGthGJk3Zps=fnyAxpqqmsSDau7ZLs4PGyZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petri Gynther <petri.gynther@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:38891 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529Ab3BYTRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 14:17:00 -0500
Received: by mail-ie0-f174.google.com with SMTP id k10so3548145iea.33
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 11:16:59 -0800 (PST)
In-Reply-To: <CAKuTDr_eC4Wrv=uGthGJk3Zps=fnyAxpqqmsSDau7ZLs4PGyZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Look at tc action redirect. Add it to ingress of eth0 to match 
everything and send out on eth1.

cheers,
jamal


On 13-02-22 07:10 PM, Petri Gynther wrote:
> Hi netdev:
>
> I'd like to hairpin two Ethernet interfaces together (e.g. eth0 and
> eth1) so that any frame received on eth0 is forwarded as-is to eth1
> and vice versa.
>
> Does Linux networking code support this? I've looked at the bridging
> code, but it doesn't seem to do this (at least trivially).
> Specifically, when eth0 and eth1 are added to bridge, unicast frames
> destined to eth0 (or eth1) MAC address end up to the bridge interface
> for local consumption, rather than being flooded to other ports on the
> bridge.
>
> Any trivial solutions to this? Can Linux bridge be configured in L2
> hub/repeater mode so that it simply floods every Rx frame to all other
> ports of the bridge?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
