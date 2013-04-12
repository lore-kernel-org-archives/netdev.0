From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lsm: export the security_skb_owned_by() function
Date: Fri, 12 Apr 2013 13:39:43 -0400 (EDT)
Message-ID: <20130412.133943.1398967886487919460.davem@davemloft.net>
References: <20130412154300.26512.67761.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130412154300.26512.67761.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 12 Apr 2013 11:43:00 -0400

> Another bit we missed when adding the skb_owned_by() hook.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

CONFIG_SECURITY is a bool, as is ipv4, so neither the definition
nor the call sites can be modular.

Therefore no export is needed.
