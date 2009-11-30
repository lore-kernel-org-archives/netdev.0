From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Mon, 30 Nov 2009 07:15:59 -0500
Message-ID: <1259583359.873.17.camel@bigi>
References: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net>
	 <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net>
	 <1259429774.3864.41.camel@bigi> <20091128190500.GB12264@sch.bme.hu>
	 <1259437442.3864.61.camel@bigi>  <20091129203508.GB18259@sch.bme.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:63046 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbZK3MP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 07:15:57 -0500
Received: by qyk32 with SMTP id 32so1492797qyk.4
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 04:16:03 -0800 (PST)
In-Reply-To: <20091129203508.GB18259@sch.bme.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-11-29 at 21:35 +0100, KOVACS Krisztian wrote:

> The story is that we really do want to deliver these packets locally, as
> if the destination IP address was locally configured on the host. The only
> way I know of to get the packet to ip_local_deliver() is by using a local
> route.

Aha, now i understand where both you and Patrick are coming from. So
you literally have to hit the main(or default) table in the reverse
source validation. How does the workaround (that you suggested) work
then? i.e you are going to fail the RTN_UNICAST test no matter what.

Dave, give me some short time to mull this over. I am not sure i like
the sysctl approach - we may have to just revert the whole thing
instead.

cheers,
jamal

