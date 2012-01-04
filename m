From: Michal Soltys <soltys@ziu.info>
Subject: Re: tc filter mask for ACK packets off?
Date: Wed, 04 Jan 2012 01:01:21 +0100
Message-ID: <4F0396D1.9030303@ziu.info>
References: <1325385056.4174.51.camel@denise.theartistscloset.com> <21734335.uCtjXOcSpA@alaris>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: =?UTF-8?B?TWljaGFsIEt1YmXEjWVr?= <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:2234 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643Ab2ADABS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 19:01:18 -0500
In-Reply-To: <21734335.uCtjXOcSpA@alaris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-01-03 08:31, Michal Kube=C4=8Dek wrote:
> On Saturday 31 of December 2011 21:30EN, John A. Sullivan III wrote:
>>  <cut>
>
> However, by a "ACK only" packet (worth prioritizing), I would rather
> understand a packet with ACK flag without any payload, not a packet w=
ith
> ACK as the only flag. For many TCP connections, all packets except
> initial SYN and SYN-ACK and two FIN packets have ACK as the only flag=
=2E
> So my guess is you should rather prioritize all TCP packets with no
> application layer data.
>
>                                                           Michal Kube=
cek

In context of the above - xtables-addons provide length2 match which=20
(possibly paired with other iptables matches) gives excellent control=20
for such tasks.
