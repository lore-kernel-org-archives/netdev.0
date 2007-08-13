From: David Miller <davem@davemloft.net>
Subject: Re: [patch 27/28] Introduce U16_MAX and U32_MAX
Date: Mon, 13 Aug 2007 13:52:22 -0700 (PDT)
Message-ID: <20070813.135222.62369884.davem@davemloft.net>
References: <200708102112.l7ALCA2M009460@imap1.linux-foundation.org>
	<20070810.153819.76325424.davem@davemloft.net>
	<alpine.LFD.0.999.0708132039200.29609@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: satyam@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934438AbXHMUwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 16:52:23 -0400
In-Reply-To: <alpine.LFD.0.999.0708132039200.29609@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>
Date: Mon, 13 Aug 2007 20:59:09 +0530 (IST)

> On Fri, 10 Aug 2007, David Miller wrote:
> 
> > 2) The reiserfs definition is going to define an equivalent
> >    value, so just adding an #undef and still letting reiserfs
> >    override is wrong.  Why put a common define in kernel.h
> >    if other headers still keep their own crufty copy too?
> 
> Because removing the (re-)definition of U32_MAX from in there in
> reiserfs_fs.h will break builds of all userspace users of U32_MAX and
> max_reiserfs_offset(), would it not? I haven't looked at any reiserfs
> userspace tools source code, so possibly none such (that use
> max_reiserfs_offset) exist, but I thought it better to be safe.
> I'll have a look at the reiserfs-utils package, just in case.

If this is the case then it would be better to pick different macro
names from the one's reiserfs already defines in it's header exported
userland interfaces.

Or, alternatively, make sure reiserfs's headers get the appropriate
headers and defines even when used in userspace.
