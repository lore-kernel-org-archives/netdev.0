From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/3] NetLabel: add the ranged tag to the CIPSOv4 protocol
Date: Wed, 29 Nov 2006 16:01:41 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611291600250.24178@d.namei>
References: <20061129181817.505281000@hp.com> <20061129182854.816890000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:22198 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1757011AbWK2VBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 16:01:44 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20061129182854.816890000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006, paul.moore@hp.com wrote:

> +{
> +	/* The constant '16' is not random, it is the maximum number of
> +	 * high/low category range pairs as permitted by the CIPSO draft based
> +	 * on a maximum IPv4 header length of 60 bytes - the BUG_ON() assertion
> +	 * does a sanity check to make sure we don't overflow the array. */
> +	int iter = -1;
> +	u16 array[16];

Perhaps in a future update, make this a value a macro definition and 
document it in the header.



-- 
James Morris
<jmorris@namei.org>
