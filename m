From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Fri, 10 Jun 2011 14:12:43 +0200
Message-ID: <20110610121241.GE17568@minipsycho.redhat.com>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
 <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
 <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com>
 <20110605.141446.1838641439880246155.davem@davemloft.net>
 <20110610083539.GB17568@minipsycho.redhat.com>
 <BANLkTinqikKoeW6mbjMV9nPii0Nzp4vSdQ@mail.gmail.com>
 <20110610093413.GC17568@minipsycho.redhat.com>
 <BANLkTimHi7V3YwbPepLyW7=pTS7hQVxEBQ@mail.gmail.com>
 <20110610103503.GD17568@minipsycho.redhat.com>
 <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pratnakarlx@gmail.com,
	ebiederm@xmission.com, shemminger@linux-foundation.org,
	greearb@candelatech.com, nicolas.2p.debian@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755652Ab1FJMN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 08:13:28 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 10, 2011 at 01:20:29PM CEST, xiaosuo@gmail.com wrote:
>On Fri, Jun 10, 2011 at 6:35 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>> Fri, Jun 10, 2011 at 11:49:27AM CEST, xiaosuo@gmail.com wrote:
>>>
>>>For hw-accel-vlan-rx, is the headroom for this header expansion
>>>reserved? I don't think so. Thanks.
>>
>> But this wasn't done for hw-accel-vlan-rx previously right? So why don't
>> check for hw-accel-vlan-rx and don do unreorder in that case?
>>
>
>Yes, it wasn't done before. We want to make the behaviors of
>hw-accel-vlan-rx and non-hw-accel-vlan-rx are the same. Is it your
>original goal of your vlan-untag patch?

You are correct. I just thought that since disabling reordering will be
most likely removed in near future, non-hw-accel-vlan-rx reorder disable
would not be needed.

>
>-- 
>Regards,
>Changli Gao(xiaosuo@gmail.com)
