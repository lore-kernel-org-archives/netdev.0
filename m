From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: return value for br_stp_recalculate_bridge_id()
Date: Tue, 29 Mar 2011 23:27:22 -0700
Message-ID: <20110329232722.31357223@s6510>
References: <1301466207-16770-1-git-send-email-dongdong.deng@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>
To: Dongdong Deng <dongdong.deng@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54751 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab1C3G11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 02:27:27 -0400
In-Reply-To: <1301466207-16770-1-git-send-email-dongdong.deng@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Mar 2011 14:23:27 +0800
Dongdong Deng <dongdong.deng@windriver.com> wrote:

> Return 'false' for "user has set a mac addr" case in
> br_stp_recalculate_bridge_id() function.
> 
> and this could address the following build warning:
> 
> net/bridge/br_stp_if.c: In function br_stp_recalculate_bridge_id:
> net/bridge/br_stp_if.c:216: warning: return with no value, in function
> returning non-void
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>

Patch has already been submitted and acke'd for this.
