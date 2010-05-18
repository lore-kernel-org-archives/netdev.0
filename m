From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: rework SR-IOV VF support
Date: Tue, 18 May 2010 08:15:15 -0700
Message-ID: <20100518081515.4190a27b@nehalam>
References: <20100518075700.GE8301@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33914 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068Ab0ERPPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 11:15:22 -0400
In-Reply-To: <20100518075700.GE8301@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 May 2010 00:57:00 -0700
Chris Wright <chrisw@sous-sol.org> wrote:

> The kernel interface changed just before 2.6.34 was released.  This brings
> iproute2 in line with the current changes.  The VF portion of setlink is
> comprised of a set of nested attributes.
> 
>   IFLA_VFINFO_LIST (NESTED)
>     IFLA_VF_INFO (NESTED)
>       IFLA_VF_MAC
>       IFLA_VF_VLAN
>       IFLA_VF_TX_RATE
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
> ---

Applied 

-- 
