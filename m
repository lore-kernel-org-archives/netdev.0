From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Fri, 24 Aug 2012 23:09:21 +0200
Message-ID: <5037ED81.5090303@gmail.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <50369A99.2070405@gmail.com> <5036EC52.9090406@redhat.com> <20120824134410.75827e0d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34978 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757675Ab2HXVIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 17:08:07 -0400
Received: by wibhr14 with SMTP id hr14so1378012wib.1
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 14:08:05 -0700 (PDT)
In-Reply-To: <20120824134410.75827e0d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/08/2012 22:44, Stephen Hemminger a =E9crit :
<snip>

> The vlan map table would be helpful, but the Spanning Tree implementa=
tion
> doesn't have a clue about what it means.

Yes, but a possibly future userland implementation of MSTP (or PVST) wo=
uld benefit from the ability=20
to manage per VLAN port states.

So at least we should have this in mind while integrating VLAN into the=
 bridge code.

	Nicolas.
