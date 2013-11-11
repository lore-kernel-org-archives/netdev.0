From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: iproute2: potential upgrade regression with 58a3e827
Date: Mon, 11 Nov 2013 14:40:47 -0800
Message-ID: <871u2mblzk.fsf@xmission.com>
References: <527D2768.1030403@canonical.com> <527E6A32.5020808@hp.com>
	<52814B88.1050708@canonical.com>
	<1384205890.2758.28.camel@dilip-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris J Arges <chris.j.arges@canonical.com>,
	Brian Haley <brian.haley@hp.com>, shemminger@osdl.org,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58232 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab3KKWkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 17:40:55 -0500
In-Reply-To: <1384205890.2758.28.camel@dilip-laptop> (Dilip Daya's message of
	"Mon, 11 Nov 2013 16:38:10 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dilip Daya <dilip.daya@hp.com> writes:

> Hi Chris,
>
> On Mon, 2013-11-11 at 15:26 -0600, Chris J Arges wrote:
>
>> Good suggestion,
>> So I'll use a more simple example now:
>> 
>> 1)
>> ip netns add first
>> ip netns exec first bash
>> 
>> 2)
>> ip netns add second
>> ip netns exec second bash
>> 
>> 3)
>> ip netns exec first bash
>> 
>> If we do not upgrade the package, after we execute (2) we have:
>> # ls -l /var/run/netns
>> total 0
>> -r-------- 1 root root 0 Nov 11 20:38 first
>> -r-------- 1 root root 0 Nov 11 20:38 second
>> 
>> If we upgrade after (1), then run (2) we have:
>> # ls -l /var/run/netns
>> total 0
>> ---------- 1 root root 0 Nov 11 20:56 first
>> -r-------- 1 root root 0 Nov 11 20:57 second
>> 
>> So looks like netns add is doing something different from 58a3e827 and on.

I will just add that it is worth looking at /proc/mounts as well.

Although I have to admit that the difference in permissions is odd.

Eric
