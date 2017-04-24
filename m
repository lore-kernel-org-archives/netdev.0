From: <Joe.Ghalam@dell.com>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Mon, 24 Apr 2017 15:01:24 +0000
Message-ID: <1493046084156.78287@Dell.com>
References: <1492618528011.11322@Dell.com>
 <20170420125512.GA9113@gondor.apana.org.au> <1492704599476.84165@Dell.com>
 <20170421044029.GA11695@gondor.apana.org.au>
 <1492785652578.53801@Dell.com>,<20170424075606.GA19926@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <Clifford.Wichmann@dell.com>,
        <netdev@vger.kernel.org>
To: <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.dell-outbound.iphmx.com ([68.232.149.220]:48368 "EHLO
        esa2.dell-outbound.iphmx.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1169984AbdDXPBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:01:54 -0400
In-Reply-To: <20170424075606.GA19926@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The only thing that can stop macvlan_process_broadcast from getting=0A=
> called is macvlan_port_destroy.  Nothing else can stop the work=0A=
> queue, unless of course the work queue mechanism itself is broken.=0A=
=0A=
> So if you're sure macvlan_port_destroy is never even called in=0A=
> your case, then you'll need to start debugging the kernel work=0A=
> queue mechanism to see why macvlan_process_broadcast is not getting=0A=
> called.=0A=
=0A=
I will get your changes reloaded and re-tested without any other debug tool=
s. Hopefully, we'll see success. I will let you know if I see any issues. =
=0A=
Btw, is your fix committed already? if not, do you know when and where it w=
ould be committed?=0A=
=0A=
Thanks,=0A=
Joe=0A=
 =
