From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/4] [IPROUTE2] iproute2: link_veth support bug fixes.
Date: Thu, 13 Sep 2007 12:30:25 +0200
Message-ID: <20070913123025.0077d421@oldman>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>
	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
	<46E7F8B1.5090907@openvz.org>
	<m1ir6fapdt.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40369 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbXIMK3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 06:29:41 -0400
In-Reply-To: <m1ir6fapdt.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 09:13:02 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Pavel Emelyanov <xemul@openvz.org> writes:
> 
> > [snip]
> >
> >> @@ -25,6 +26,3 @@ clean:
> >>  
> >>  LDLIBS	+= -ldl
> >>  LDFLAGS	+= -Wl,-export-dynamic
> >> -
> >> -%.so: %.c
> >> -	$(CC) $(CFLAGS) -shared $< -o $@
> >
> > %) How do we get the .so file then?
> 
> The code was built into iproute2, so we don't need the .so file.
> That rule does not work on arch/x86_64 so I had to do something
> and the easiest was to simply compile the code in.  Like Patrick
> did with his recent VLAN support.
> 
> The usefulness of a .so file seems to be distributing the code
> outside of /bin/ip.  Although I think we currently have some issues with
> mixed 32bit and 64bit systems because we have "/usr/lib/ip/link_*.so"
> hard coded.
> 
> A .so file always seems to override the compiled in version so I don't
> think we loose any flexibility on that front.
> 
> Eric

Fixing the 64 bit library path is on my to fix list.
