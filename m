From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Fri, 10 Jun 2011 19:20:29 +0800
Message-ID: <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org> <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
 <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com> <20110605.141446.1838641439880246155.davem@davemloft.net>
 <20110610083539.GB17568@minipsycho.redhat.com> <BANLkTinqikKoeW6mbjMV9nPii0Nzp4vSdQ@mail.gmail.com>
 <20110610093413.GC17568@minipsycho.redhat.com> <BANLkTimHi7V3YwbPepLyW7=pTS7hQVxEBQ@mail.gmail.com>
 <20110610103503.GD17568@minipsycho.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, pratnakarlx@gmail.com,
	ebiederm@xmission.com, shemminger@linux-foundation.org,
	greearb@candelatech.com, nicolas.2p.debian@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34181 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab1FJLUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 07:20:49 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so2091615bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 04:20:49 -0700 (PDT)
In-Reply-To: <20110610103503.GD17568@minipsycho.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2011 at 6:35 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Fri, Jun 10, 2011 at 11:49:27AM CEST, xiaosuo@gmail.com wrote:
>>
>>For hw-accel-vlan-rx, is the headroom for this header expansion
>>reserved? I don't think so. Thanks.
>
> But this wasn't done for hw-accel-vlan-rx previously right? So why don't
> check for hw-accel-vlan-rx and don do unreorder in that case?
>

Yes, it wasn't done before. We want to make the behaviors of
hw-accel-vlan-rx and non-hw-accel-vlan-rx are the same. Is it your
original goal of your vlan-untag patch?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
