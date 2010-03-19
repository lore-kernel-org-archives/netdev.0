From: thomas yang <lampsu@gmail.com>
Subject: Re: [iproute2] iproute2 question
Date: Fri, 19 Mar 2010 13:53:23 +0800
Message-ID: <f4f837ab1003182253x12727855k118f7d67115daf23@mail.gmail.com>
References: <f4f837ab1003180202h6b2d5ed0ledd2a24dfd2627df@mail.gmail.com>
	 <20100318085919.05328127@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f198.google.com ([209.85.216.198]:62560 "EHLO
	mail-px0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab0CSFxX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:53:23 -0400
Received: by pxi36 with SMTP id 36so2035520pxi.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:53:23 -0700 (PDT)
In-Reply-To: <20100318085919.05328127@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/3/18 Stephen Hemminger <shemminger@vyatta.com>:
> On Thu, 18 Mar 2010 17:02:16 +0800
> thomas yang <lampsu@gmail.com> wrote:
>
>> Hi,
>>
>> Linux router R (has some interfaces) =A0use the table "main" as defa=
ult
>> routing table to route packets. =A0If =A0some link connected to R fa=
iled,
>> I want to use another table "backup_tbl" to route packets; if the
>> broken link repaired , go back to use table "main" =A0. =A0How to do=
 this?
>
> That's now it works. Use a real routing daemon.
>

I want to reduce the packet loss that happens while routers converge
after a topology change due to a failure, use precalculated backup
table to do rapid failure repair  (repair faster than routing daemon,
fast reroute).
I do static routing on my linux routers.  When  some link  failed,
 I want to  use backup tables to route packets.  Can iproute2 do this?
