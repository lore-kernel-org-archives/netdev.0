From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] via-rhine: hardware VLAN support
Date: Mon, 8 Nov 2010 12:53:57 -0800
Message-ID: <AANLkTim40QH2AWz8YtW_y3=WjEU0_Rom9-CPFj-O5MCt@mail.gmail.com>
References: <20101105104303.GA8325@core.hellgate.ch>
	<AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
	<20101108162132.GA32728@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46697 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011Ab0KHUyA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:54:00 -0500
Received: by eye27 with SMTP id 27so3111279eye.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 12:53:58 -0800 (PST)
In-Reply-To: <20101108162132.GA32728@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 8, 2010 at 8:21 AM, Roger Luethi <rl@hellgate.ch> wrote:
> On Fri, 05 Nov 2010 11:31:56 -0700, Jesse Gross wrote:
>> On Fri, Nov 5, 2010 at 3:43 AM, Roger Luethi <rl@hellgate.ch> wrote:
>> > This patch adds VLAN hardware support for Rhine chips.
>>
>> This uses the old interfaces for vlan acceleration. =A0We're working=
 to
>> switch drivers over to use the new methods and the old ones will be
>> going away in the future. =A0It would be great if we can avoid addin=
g
>> more code that uses those interfaces.
>
> Can you point me to a driver that has been switched to use the new me=
thods
> already? Is there some other form of documentation?

bnx2 is an example of a driver that has been converted.  The commit
that actually made the change was
7d0fd2117e3d0550d7987b3aff2bfbc0244cf7c6, which should highlight the
differences.  A key point is that drivers should no longer reference
vlan groups at all.
