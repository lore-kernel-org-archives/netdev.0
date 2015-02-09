From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: Only set TUNNEL_VXLAN_OPT if
 VXLAN-GBP metadata is set
Date: Mon, 09 Feb 2015 14:27:20 -0800 (PST)
Message-ID: <20150209.142720.1523386523328652970.davem@redhat.com>
References: <27de6976a7a40d1da2875b93138353724cbfa24b.1423497309.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46035 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761222AbbBIW1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 17:27:46 -0500
In-Reply-To: <27de6976a7a40d1da2875b93138353724cbfa24b.1423497309.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon,  9 Feb 2015 16:56:37 +0100

> This avoids setting TUNNEL_VXLAN_OPT for VXLAN frames which don't
> have any GBP metadata set. It is not invalid to set it but unnecessary.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
