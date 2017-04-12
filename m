From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/1] L2TP device MTU setup - tunnel socket
 needs a lock
Date: Wed, 12 Apr 2017 10:13:00 -0400 (EDT)
Message-ID: <20170412.101300.1946293471196203044.davem@davemloft.net>
References: <alpine.DEB.2.11.1704112010410.8819@nelson51.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kleptog@svana.org, jchapman@katalix.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: parameswaran.r7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1704112010410.8819@nelson51.eng.vyatta.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Tue, 11 Apr 2017 20:14:37 -0700 (PDT)

> 
> The MTU overhead calculation in L2TP device set-up
> merged via commit b784e7ebfce8cfb16c6f95e14e8532d0768ab7ff
> needs to be adjusted to lock the tunnel socket while
> referencing the sub-data structures to derive the
> socket's IP overhead.

This is missing a proper signoff.

The subject line also needs to be fixed "[PATCH net-next] l2tp: " as explained
by Guillaume.

Thanks.
