From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, REVERT] Re: [forcedeth bug] Re: [GIT] Networking
Date: Fri, 05 Aug 2011 03:19:53 -0700 (PDT)
Message-ID: <20110805.031953.239005825626336696.davem@davemloft.net>
References: <20110801151308.GA31256@elte.hu>
	<20110804215354.GA7056@elte.hu>
	<20110805101625.GA11502@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110805101625.GA11502@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 5 Aug 2011 12:16:25 +0200

> I have reverted the two forcedeth commits:
> 
>   0891b0e08937: forcedeth: fix vlans
>   3326c784c9f4: forcedeth: do vlan cleanup
> 
> and also reverted two vlan commits that the pre-cleanup driver 
> depended on:
> 
>   ffcf9b767293: vlan: kill vlan_gro_frags and vlan_gro_receive
>   7890a5b9cbfd: vlan: kill ndo_vlan_rx_register
> 
> and this finally gave me a working forcedeth driver. I've attached 
> the working revert below.

Jiri please diagnose this immediately otherwise I will have to apply
Ingo's reverts.

Ingo has been reporting this regression for days and you haven't said
anything.  That's not acceptable.
