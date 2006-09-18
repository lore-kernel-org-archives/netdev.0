From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v02: Enforcement for SELinux
Date: Mon, 18 Sep 2006 14:55:51 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609181452300.5976@d.namei>
References: <45019F72.2050708@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:61418 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932174AbWIRSzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 14:55:53 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F72.2050708@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> This defines SELinux enforcement of the 2 new LSM hooks.
> 

I think this looks ok in general (I have a couple more technical issues), 
athough I believe that Stephen has some question about policy 
construction.

Please rename these hooks:

	+ * @skb_policy_check:
	+ * @skb_netfilter_check

to:

	skb_flow_in
	skb_flow_out



- James
-- 
James Morris
<jmorris@namei.org>
