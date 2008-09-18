From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Thu, 18 Sep 2008 10:38:31 +0200
Message-ID: <f4845fc0809180138x1eb793ebq153a54c46373bd90@mail.gmail.com>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
	 <Pine.LNX.4.64.0809131100320.20936@wm7d.net>
	 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com>
	 <Pine.LNX.4.64.0809131835001.12375@wm7d.net>
	 <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com>
	 <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
	 <20080915014337.GA10026@verge.net.au>
	 <f4845fc0809161345r2f24cfa4sf33bd9173f50041b@mail.gmail.com>
	 <Pine.LNX.4.64.0809171552030.9336@wm7d.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Simon Horman" <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, j.stubbs@linkthink.co.jp,
	"=?ISO-8859-1?Q?Siim_P=F5der?=" <siim@p6drad-teel.net>,
	"Vince Busam" <vbusam@google.com>
To: "Joseph Mack NA3T" <jmack@wm7d.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809171552030.9336@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2008 at 12:53 AM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> On Tue, 16 Sep 2008, Julius Volz wrote:
>
>> Amazingly, the first SYN and the SYN/ACK of a TCP connection to the
>> VIP:vport do not traverse the NAT chain in POSTROUTING at all
>
> :-(
>
>> (verified by LOG target),
>
> you didn't see the packets in the logs?

Exactly. No matter what I do, only the ACK in response to the SYN/ACK
appears in the logs. With SNAT without IPVS, the SYN packet correctly
enters the chain/table.

I haven't found anything in the IPVS or Netfilter code yet that could
cause this problem...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
