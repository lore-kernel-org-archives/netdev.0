From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: add flow director support
Date: Tue, 13 Apr 2010 11:11:06 +0800
Message-ID: <k2k412e6f7f1004122011ra459e1b5q6baa235d7a0e4d7@mail.gmail.com>
References: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
	<z2o65634d661004120634h8336409er33af1fb75c2a9d1b@mail.gmail.com>
	<u2m412e6f7f1004120727ga219ab9dr75ee522fba6f63c6@mail.gmail.com>
	<h2m65634d661004121013uf2c86b81ndded3bb138dee7a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:50315 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683Ab0DMDL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 23:11:27 -0400
Received: by iwn35 with SMTP id 35so1623278iwn.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 20:11:26 -0700 (PDT)
In-Reply-To: <h2m65634d661004121013uf2c86b81ndded3bb138dee7a9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 1:13 AM, Tom Herbert <therbert@google.com> wrot=
e:
> On Mon, Apr 12, 2010 at 7:27 AM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
>> On Mon, Apr 12, 2010 at 9:34 PM, Tom Herbert <therbert@google.com> w=
rote:
>>
>
> Ideally, this should replace rps_cpus if it's a better interface....
> right now these would be conflicting interfaces.
>

How about sw-rxs and sw-rx-$ (SoftWare Receive queue). It is a
software emulation of hardware receive queue, as softnet to NIC.
sw-rx-$ is equivalent of /proc/irq/$/smp_affinity, only cpuid is
instead of cpumask.

Does anyone support this interface replacing the current rps_cpus? I do=
=2E :)

>
> It's probably a little more work, but the CPU->weight mappings could
> be implemented to cause minimal disruption in the rps_map. =C2=A0Also=
, if
> OOO is an issue, then the mitigation technique in RFS could be applie=
d
> (this will work best when hash table is larger I believe).
>

I am thinking about the cost of keeping packets in order. Is it really
worth for this kind of random migration?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
