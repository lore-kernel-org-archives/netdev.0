From: Paul Moore <paul.moore@hp.com>
Subject: Re: LSPP kernels (was Re: [PATCH]: SAD sometimes has double SAs).
Date: Wed, 28 Mar 2007 12:36:57 -0400
Message-ID: <200703281236.58222.paul.moore@hp.com>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com> <1175094915.3085.503.camel@faith.austin.ibm.com> <Line.LNX.4.64.0703281213060.2266@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joy Latten <latten@austin.ibm.com>,
	David Miller <davem@davemloft.net>,
	Eric Paris <eparis@redhat.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Steve G <linux_4ever@yahoo.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, selinux@tycho.nsa.gov
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:34111 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933055AbXC1Qhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 12:37:36 -0400
In-Reply-To: <Line.LNX.4.64.0703281213060.2266@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, March 28 2007 12:20:24 pm James Morris wrote:
> On Wed, 28 Mar 2007, Joy Latten wrote:
> > Eric, sorry as I know you already patched lspp kernel
> > for testing.
>
> I think it'd be better to have the lspp kernel join the upstream workflow
> process, rather than being a shortcut into RHEL.
>
> Please consider creating an lspp git tree (based off Linus' tree), then
> once patches there are tested and ready to submit upstream, post them here
> or selinux-list, where they can be reviewed and applied to either my or
> DaveM's git tree.
>
> From there, they'll be picked up in -mm for even wider testing then be
> merged into mainline as appropriate.  Then, they can be incorporated into
> distro devel kernels when they update their kernels, or backported to
> stable distro kernels as already reviewed & tested upstream patches.
>
> If there are any objections, please respond.

I think the original intent of the LSPP kernel "series" was to test patches 
before they were submitted to a wider audience (not too different from what 
you are describing).  Eric Paris became the LSPP/MLS group's Andrew Morton if 
you will :)

However, for whatever reason, things appear to have stumbled a bit in recent 
months and I think making an effort to move to a more standard approach based 
on current kernel development would be a step in the right direction.  This 
would probably make backports a bit more difficult but Eric's a smart guy and 
I'm sure he wouldn't mind :)

Does anyone have access to a public site we could use to host a git tree?  If 
no one has anything available (or is willing to maintain the tree) I might be 
able to do something.

-- 
paul moore
linux security @ hp
