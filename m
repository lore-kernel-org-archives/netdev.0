From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: network namespace bloat
Date: Wed, 11 Feb 2015 18:09:44 +0100
Message-ID: <54DB8CD8.8080102@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>	<87k2zubw7l.fsf@x220.int.ebiederm.org> <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	roopa <roopa@cumulusnetworks.com>, hannes@stressinduktion.org,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	David Ahern <dsahern@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:38020 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbbBKRJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 12:09:47 -0500
Received: by mail-wg0-f46.google.com with SMTP id a1so4830947wgh.5
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 09:09:46 -0800 (PST)
In-Reply-To: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/02/2015 03:42, Eric W. Biederman a =C3=A9crit :
[snip]
>
> The next largest component appears to be all of the tunnel network
> devices that we allocate for compatibility reasons so that the old io=
ctl
> interfaces still work.
>
[snip]
>
>
> A knob (sysctl?) that controls the creation of the backwards
> compabitilty tunnel network devices seems desirable.  As in many
> instances those are just overhead today.
Note that these interfaces are also used as fallback devices, they catc=
h
packets that don't match any configured tunnels.

See: http://thread.gmane.org/gmane.linux.network/249634/focus=3D249634

[snip]
>
> In my ideal world enough of these issues would be fixed that a
> new empty network namespace would consume less than 100KiB of memory.
+1


Regards,
Nicolas
