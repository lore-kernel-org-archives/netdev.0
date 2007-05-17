From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from invalid context
	at net/core/sock.c:1523
Date: Thu, 17 May 2007 08:04:29 +0200
Message-ID: <1179381869.10069.112.camel@violet>
References: <1179317775.10069.77.camel@violet>
	 <Pine.LNX.4.64.0705161418250.25986@twin.jikos.cz>
	 <Pine.LNX.4.64.0705170102290.13706@twin.jikos.cz>
	 <20070516.161609.108116976.davem@davemloft.net>
	 <Pine.LNX.4.64.0705170116260.13706@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, satyam.sharma@gmail.com,
	Greg KH <gregkh@suse.de>, jeremy@goop.org, maxk@qualcomm.com,
	bluez-devel@lists.sourceforge.net, clg@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jikos@jikos.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760861AbXEQGEu@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0705170116260.13706@twin.jikos.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

> > > I have just verified that this locking scheme is indeed correct. So you 
> > > can add
> > > 
> > > 	Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> > > 
> > > if you wish to, and submit the patch to Andrew.
> > I guess I don't get sent networking patches any more?
> > :-)
> 
> Well, this is bluetooth-specific, but it seemed to me that Marcel wasn't 
> going to send pull requests to Linus any time soon, therefore I thought 
> going through akpm is a thing to do.

actually everything net/ related goes to Dave first. No exception. This
includes the Bluetooth subsystem. I even send drivers/bluetooth/ through
Dave before they go to Linus.

> Honestly, I really don't care through which tree this goes in, so sorry if 
> any offence was caused here :)

Having these small ones passed through Andrew is only a convenience
since he is really good in picking them up and make sure that they get
merged by Linus.

Regards

Marcel
