From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Fri, 14 Dec 2012 08:50:33 -0800
Message-ID: <87zk1g8tnq.fsf@xmission.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
	<87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com>
	<87zk1jht7d.fsf@xmission.com> <87sj7beyc1.fsf@xmission.com>
	<50CA135A.7060802@6wind.com> <87mwxh6a8y.fsf@xmission.com>
	<50CB5047.8060804@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43025 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756224Ab2LNQuq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 11:50:46 -0500
In-Reply-To: <50CB5047.8060804@6wind.com> (Nicolas Dichtel's message of "Fri,
	14 Dec 2012 17:13:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 13/12/2012 20:08, Eric W. Biederman a =C3=A9crit :

>> No.  The difficulty monitoring which network namespaces are being us=
ed
>> is an unintended side effect.
> Why is netlink a bad idea? Having a way to know all existing netns is=
 a start
> point to monitor netns, isn't it?

In the same way that having a neighbour table that contains all existin=
g
ip address to mac addresses mappings is a starting point to monitor all
existing hosts.

All does not scale.

All removes a lot of perfectly valid use cases like checkpoint-restart,
and nesting containers.

All as different from what is already implemented requires implementing
yet another namespace to put the names of all into it.  We have enough
namespaces now thank you very much.

An unfiltered global list is about as interesting to use as putting
all files in /.  Sure you know which directory you put your file in but
which file is it?

What has already been implemented should be roughly as good for
monitoring as what is available with lsof.

And of course there is the fact that a global list of anything that is
the same from every perspective violates the principle of relativity,
and is in contradiction with the phsical reality in which we exist.

So there is no way that having a global all inclusive list of network
namespaces makes the least lick of sense and I really don't want to
think about it.

Eric
