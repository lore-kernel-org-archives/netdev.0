From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support.
Date: Mon, 09 Apr 2007 13:46:31 -0700 (PDT)
Message-ID: <20070409.134631.71091422.davem@davemloft.net>
References: <20070409.133753.108740229.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329029E3EE5@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965663AbXDIUqc@vger.kernel.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029E3EE5@orsmsx414.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 9 Apr 2007 13:43:11 -0700

> True, but the assignment for "dev" above also casts this void * to
> struct net_device *:
> 
>         dev = (struct net_device *)
>                 (((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
>         dev->padded = (char *)dev - (char *)p;
> 
> Shall I remove my cast?

I think so.  Casts tend to be red flags during patch review,
so don't add them when not necessary and let's remove the
unnecessary ones too.
