From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v7 9/9] xen-netback: Aggregate TX unmap
 operations
Date: Thu, 20 Mar 2014 10:48:55 +0000
Message-ID: <20140320104855.GA16285@zion.uk.xensource.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
 <1394142511-14827-10-git-send-email-zoltan.kiss@citrix.com>
 <532A0915.5090006@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <532A0915.5090006@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 09:16:05PM +0000, Zoltan Kiss wrote:
> Hi,
> 
> I'm thinking about revoking this patch: it's value is pretty small,
> but it causes performance regression on Win7 guests. And probably it
> is not the best solution for this problem. It might be the delay it
> takes the dealloc thread to be scheduled is enough.
> What do you think?
> 

Can you elaborate? What makes Win7 so special? What's performance
impact to other guests?

Wei.
