From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: Supermicro AOC-STGN-i2S w intel 82599ES on Brocade ICX6610 -
 random link failures
Date: Mon, 25 Jan 2016 18:44:11 +0800
Message-ID: <56A5FC7B.3020803@gmail.com>
References: <20160125100851.GA7545@nbnik.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nik@linuxbox.cz, Stanislav Schattke <schattke@linuxbox.cz>
To: Nikola Ciprich <nikola.ciprich@linuxbox.cz>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33294 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756393AbcAYKno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 05:43:44 -0500
Received: by mail-pa0-f45.google.com with SMTP id cy9so79200142pac.0
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 02:43:44 -0800 (PST)
In-Reply-To: <20160125100851.GA7545@nbnik.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://www.mail-archive.com/netdev@vger.kernel.org/msg94109.html

Maybe this link can help you. If work, please let me know.

Thanks a lot.
Zhu Yanjun

On 01/25/2016 06:08 PM, Nikola Ciprich wrote:
> Hello netdev readers,
>
> I'd like to consult following problem we're dealing with:
>
> I have a cluster of three nodes connected to stacked Brocade ICX6610
> switches using bonded AOC-STGN-i2S adapters (they're using 82599ES
> chipsets).
>
> The problem is, I see random link failures on practically all
> interfaces. Link always goes down for very short time, then adapter
> is reset and link goes up again.
>
> Here's dmesg snippet:
>
> [Jan22 22:09] ixgbe 0000:03:00.0 eth0: NIC Link is Down
> [  +0.005610] ixgbe 0000:03:00.0 eth0: initiating reset to clear Tx work after link loss
> [  +0.012792] bond0: link status definitely down for interface eth0, disabling it
> [  +1.105826] ixgbe 0000:03:00.0 eth0: Reset adapter
> [  +0.307518] ixgbe 0000:03:00.0 eth0: detected SFP+: 3
> [  +0.145881] ixgbe 0000:03:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control: RX/TX
>
> since I'm using bonding, it doesn't disrupt traffic, but I'd still like to
> resolve it. We're using 5m passive SFP cables, we tried replacing one with 3m
> piece, to no avail.
>
> all three boxes are supermicro X10DRW, running vanilla x86_64 4.0.5 kernel (I'll upgrade it to 4.1.16 soon)
>
> we were using broadcom adapter before and they were working without such problems
> (except for one particular port, which showed mysterious packet drops every few
> months, thats why we switched to intel-based adapters), so I think cables and switches
> should be fine, but I'm not sure of course
>
> I think I've seen similar problems and they were PM related, but I'm not sure..
>
> anyone seen similar problem?
>
> or some tips on how could I debug it?
>
> If I could provide more information, please let me know
>
> BR
>
> nik
>
