From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2 net] net: Always untag vlan-tagged traffic on input.
Date: Mon, 29 Sep 2014 14:44:57 +0200
Message-ID: <54295449.7030203@6wind.com>
References: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vladislav Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:53117 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbaI2MpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 08:45:00 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so920247wid.1
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 05:44:59 -0700 (PDT)
In-Reply-To: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/08/2014 20:42, Vladislav Yasevich a =C3=A9crit :
[snip]
>
> The patch attempt to fix this another way.  It moves the vlan header
> stipping code out of the vlan module and always builds it into the
> kernel network core.  This way, even if vlan is not supported on
> a virtualizatoin host, the virtual machines running on top of such
> host will still work with VLANs enabled.
After this patch (0d5501c1c828 ("net: Always untag vlan-tagged traffic =
on
input.")), tcpdump will not be able to display the VLAN header on input=
 path.
Is this really intended?


Regards,
Nicolas
