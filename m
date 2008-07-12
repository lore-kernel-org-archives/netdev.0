From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 12 Jul 2008 11:26:10 +0400
Message-ID: <20080712072610.GA8675@2ka.mipt.ru>
References: <20080707180736.GA15687@2ka.mipt.ru> <20080707181019.GC15687@2ka.mipt.ru> <20080712070150.GD13483@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Pavel Machek <pavel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:42932 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829AbYGLH0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2008 03:26:13 -0400
Content-Disposition: inline
In-Reply-To: <20080712070150.GD13483@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sat, Jul 12, 2008 at 09:01:51AM +0200, Pavel Machek (pavel@suse.cz) wrote:
> > + * Completely async processing of all events (hard, symlinks and rename are the
> > + 	only exceptions) including object creation and data reading and writing.
> 
> Hmm... this is little funny.
> 
> 	Async processing of most events (only exceptions are ...) ?

There are people who belive that most with exceptions is still all :)
Actually I think that if there are exceptions, than it is not 'all'.
 
> > +POHMELFS network protocol.
> > +
> > +Basic structure used in network communication is following command:
> > +
> > +struct netfs_cmd
> > +{
> > +	__u16			cmd;	/* Command number */
> > +	__u16			csize;	/* Attached crypto information size */
> > +	__u16			cpad;	/* Attached padding size */
> > +	__u16			ext;	/* External flags */
> > +	__u32			size;	/* Size of the attached data */
> > +	__u32			trans;	/* Transaction id */
> > +	__u64			id;	/* Object ID to operate on. Used for feedback.*/
> > +	__u64			start;	/* Start of the object. */
> > +	__u64			iv;	/* IV sequence */
> > +	__u8			data[0];
> > +};
> 
> Which endianity?

Big endian in the network. CPU endian on both ends.

-- 
	Evgeniy Polyakov
