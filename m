From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Fix serialization of non-masked
 set actions.
Date: Tue, 03 Mar 2015 14:39:45 -0500 (EST)
Message-ID: <20150303.143945.661201418308735762.davem@davemloft.net>
References: <1425350996-2930-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, jrajahalme@nicira.com
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425350996-2930-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Mon,  2 Mar 2015 18:49:56 -0800

> Set actions consist of a regular OVS_KEY_ATTR_* attribute nested inside
> of a OVS_ACTION_ATTR_SET action attribute. When converting masked actions
> back to regular set actions, the inner attribute length was not changed,
> ie, double the length being serialized. This patch fixes the bug.
> 
> Fixes: 83d2b9b ("net: openvswitch: Support masked set actions.")
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> This fix needs to be applied to net as well; it applies cleanly.

This is backwards, don't do this.  Just say that 'net' needs the fix
and submit it targetting that tree only.  Things in 'net' propagate
into 'net-next' automatically as I do merges over time, but the
opposite is not true.
