From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net: Utility function to get affinity_hint by policy
Date: Mon, 3 Mar 2014 11:07:14 +0200
Message-ID: <20140303090712.GA32719@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1393769771-16196-1-git-send-email-amirv@mellanox.com>
 <1393769771-16196-2-git-send-email-amirv@mellanox.com>
 <alpine.LNX.2.03.1403031409040.18716@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, prarit@redhat.com
To: Govindarajulu Varadarajan <gvaradar@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:38929 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaCCJHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 04:07:18 -0500
Received: by mail-we0-f177.google.com with SMTP id u57so964972wes.8
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 01:07:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.03.1403031409040.18716@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/14 14:14 +0530, Govindarajulu Varadarajan wrote:
> 
> 
> On Sun, 2 Mar 2014, Amir Vadai wrote:
> 
[...]
> >+
> >+	for_each_cpu(affinity_cpu, non_numa_cores_mask) {
> >+		if (--rxq < 0)
> >+			goto out;
> >+	}
> >+
> >+	goto err;
> 
> Hi Amir
> 
> Here ret should have a non-zero value right? Since we failed to find an
> affinity hint.
> 
> thanks
> govind
> 

Right. Will add it to V2

Thanks,
Amir
