From: "Jay Hernandez" <jay@chelsio.com>
Subject: RE: linux-next: build failure after merge of the net tree
Date: Wed, 3 Oct 2012 19:12:38 -0700
Message-ID: <8A71B368A89016469F72CD08050AD3340C527BB9@maui.asicdesigners.com>
References: <20121004101833.019598b7e474c7b74e67ff20@canb.auug.org.au><20121003.205053.1711360628623711137.davem@davemloft.net><20121004110615.3fda3c25735284c776106d7d@canb.auug.org.au> <20121003.214750.2022020970468412510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Vipul Pandya" <vipul@chelsio.com>,
	"Jay Hernandez" <jay@chelsio.com>
To: "David Miller" <davem@davemloft.net>, <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27426 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab2JDCMn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 22:12:43 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David and Stephen,

I apologize for not taking the necessary steps to verify our patches
before submission. Ignorance is not an excuse... Anyways David thank you
for fixing the issue for us.

Jay-

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, October 03, 2012 6:48 PM
To: sfr@canb.auug.org.au
Cc: netdev@vger.kernel.org; linux-next@vger.kernel.org;
linux-kernel@vger.kernel.org; Vipul Pandya; Jay Hernandez
Subject: Re: linux-next: build failure after merge of the net tree

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 4 Oct 2012 11:06:15 +1000

> Actually, for me it is.  I have a script that does the "use 
> yesterday's version" for me.  To fix (even a one liner) means bringing

> up an editor, commiting, creating the patch and then recommiting it 
> (an implementation
> detail) and recording that I need to keep (automatically) applying the

> patch in case the maintainer doesn't react quickly.

Ok, fair enough.

I'll try to look into making x86 barf when a vmalloc.h include is
missing.
