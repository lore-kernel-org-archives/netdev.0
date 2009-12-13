From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Sun, 13 Dec 2009 14:11:50 -0500
Message-ID: <1260731510.6167.25.camel@bigi>
References: <1259585129.3992.13.camel@nienna.balabit>
	 <1259589577.873.30.camel@bigi> <1259674488.3168.45.camel@bigi>
	 <20091202.223117.228943068.davem@davemloft.net>
	 <1259848398.3766.43.camel@bigi>  <4B17C346.3000906@trash.net>
	 <1259849264.13245.3.camel@nienna.balabit>  <1259850594.3766.46.camel@bigi>
	 <1260723147.6167.20.camel@bigi>
	 <Pine.LNX.4.58.0912132009410.12698@u.domain.uli>
	 <1260729530.6167.22.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-4NMqZVfm2GO+UKYeDHgh"
Cc: Julian Anastasov <ja@ssi.bg>, KOVACS Krisztian <hidden@balabit.hu>,
	Patrick McHardy <kaber@trash.net>, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:64463 "HELO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753910AbZLMTMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 14:12:01 -0500
Received: by qyk30 with SMTP id 30so1219457qyk.33
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 11:12:00 -0800 (PST)
In-Reply-To: <1260729530.6167.22.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4NMqZVfm2GO+UKYeDHgh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2009-12-13 at 13:38 -0500, jamal wrote:

> Of course. I will resend ..

Updated. Much thanks Julian.

cheers,
jamal


--=-4NMqZVfm2GO+UKYeDHgh
Content-Disposition: attachment; filename="src-valid-m2"
Content-Type: application/mbox; name="src-valid-m2"
Content-Transfer-Encoding: 7bit

>From 2a69541430da1a888605e6092f5b35a76efd8475 Mon Sep 17 00:00:00 2001
From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Sun, 13 Dec 2009 14:02:46 -0500
Subject: [PATCH] [PATCH] net: restore ip source validation

when using policy routing and the skb mark:
there are cases where a back path validation requires us
to use a different routing table for src ip validation than
the one used for mapping ingress dst ip.
One such a case is transparent proxying where we pretend to be
the destination system and therefore the local table
is used for incoming packets but possibly a main table would
be used on outbound.
Make the default behavior to allow the above and if users
need to turn on the symmetry via sysctl src_valid_mark

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

-- 
1.5.6.5


--=-4NMqZVfm2GO+UKYeDHgh--

