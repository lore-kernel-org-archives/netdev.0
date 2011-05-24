From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2]net:8021q:vlan.c Fix pr_info to just give the vlan
 fullname and version.
Date: Tue, 24 May 2011 02:21:44 -0400 (EDT)
Message-ID: <20110524.022144.2121988243667976554.davem@davemloft.net>
References: <1306215647-2857-1-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, greearb@candelatech.com
To: justinmattock@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306215647-2857-1-git-send-email-justinmattock@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Justin P. Mattock" <justinmattock@gmail.com>
Date: Mon, 23 May 2011 22:40:47 -0700

> The below patch removes vlan_buggyright and vlan_copyright from vlan_proto_init, 
> so that it prints out just the fullname of vlan and the version number.

Come on Justin, you're making various strings now completely
unreferenced.  Don't just leave them there, remove them.
