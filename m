From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from invalid context
 at net/core/sock.c:1523
Date: Wed, 16 May 2007 16:16:09 -0700 (PDT)
Message-ID: <20070516.161609.108116976.davem@davemloft.net>
References: <1179317775.10069.77.camel@violet>
	<Pine.LNX.4.64.0705161418250.25986@twin.jikos.cz>
	<Pine.LNX.4.64.0705170102290.13706@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam.sharma@gmail.com, marcel@holtmann.org, gregkh@suse.de,
	jeremy@goop.org, maxk@qualcomm.com,
	bluez-devel@lists.sourceforge.net, clg@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jikos@jikos.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757466AbXEPXQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 19:16:02 -0400
In-Reply-To: <Pine.LNX.4.64.0705170102290.13706@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jikos@jikos.cz>
Date: Thu, 17 May 2007 01:03:55 +0200 (CEST)

> On Wed, 16 May 2007, Jiri Kosina wrote:
> 
> > > since Jiri has a good test case for it, I leave it to him for testing.
> > > If he confirms that this fixes the locking issues, then this is
> > > Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
> > I will verify later this evening and will let you know. I am however 
> > pretty convinced now that this is the right fix.
> 
> Satyam,
> 
> I have just verified that this locking scheme is indeed correct. So you 
> can add
> 
> 	Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> 
> if you wish to, and submit the patch to Andrew.

I guess I don't get sent networking patches any more?
:-)
