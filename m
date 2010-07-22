From: Peter Chacko <peterchacko35@gmail.com>
Subject: Re: Lost in iptables code.
Date: Fri, 23 Jul 2010 00:07:20 +0530
Message-ID: <AANLkTillnq9VXLCRWoSJMXNCEX8TGmnJQ5ChSoy9Ix0O@mail.gmail.com>
References: <4C4887D0.3050309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48877 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab0GVShV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 14:37:21 -0400
Received: by iwn7 with SMTP id 7so8070047iwn.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 11:37:20 -0700 (PDT)
In-Reply-To: <4C4887D0.3050309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

follow NF_HOOKS.

On Thu, Jul 22, 2010 at 11:32 PM, Ben Greear <greearb@candelatech.com> =
wrote:
> I'm trying to debug an appearant bug in the "CT zones"
> logic in 2.6.34, and I'm having a hard time figuring out where the
> code enters the iptables logic. =A0(In case it matters, the
> CT Zones logic is related to the 'raw' table.)
>
> I assume it would be somewhere in netif_receive_skb,
> but I don't see anything obvious.
>
> If anyone has suggestions where to start poking at this,
> please let me know.
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =A0http://www.candelatech.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
