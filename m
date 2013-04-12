From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/7] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Fri, 12 Apr 2013 05:58:19 -0700
Message-ID: <1365771499.4459.2.camel@edumazet-glaptop>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
	 <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
	 <20130411200401.GJ5936@zion.uk.xensource.com>
	 <1365754684.8126.82.camel@zakaz.uk.xensource.com>
	 <20130412084822.GA11321@zion.uk.xensource.com>
	 <1365757035.15783.4.camel@zakaz.uk.xensource.com>
	 <20130412093433.GD11321@zion.uk.xensource.com>
	 <1365759801.15783.11.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:43997 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab3DLM6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 08:58:22 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so1414300pbc.30
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 05:58:21 -0700 (PDT)
In-Reply-To: <1365759801.15783.11.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 10:43 +0100, Ian Campbell wrote:
> On Fri, 2013-04-12 at 10:34 +0100, Wei Liu wrote:

> > But we don't have handle on this. If I understand correctly the
> > discussion in other thread, 90 is empirical value, not something
> > documented.
> 
> My original question was effectively "is anyone else going to be
> interested in this empirical value", if so then it seems like it would
> be useful to have it centrally defined.
> 

This could be MAX_TCP_HEADER. Probably a bit overestimated but do we
care ?
