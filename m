From: Neil Horman <nhorman@redhat.com>
Subject: Re: Does a forwarded packet has a local socket with it?
Date: Mon, 18 Apr 2005 14:04:03 -0400
Message-ID: <20050418180403.GD31824@hmsendeavour.rdu.redhat.com>
References: <20050418140348.33642.qmail@web51509.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Park Lee <parklee_sel@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050418140348.33642.qmail@web51509.mail.yahoo.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2005 at 07:03:47AM -0700, Park Lee wrote:
> On Mon, 18 Apr 2005 at 08:03, jamal wrote:
> > simple answer: no
> 
> Thank you very much.
> 
> Still, Does a forwarded packet also have no any kernel
> socket with it?  i.e. Is a forwarded packet not
> associated with any socket at all? 
Not on the fowarding machine, no.  There is no need for a socket, since a socket
just defines an endpoint for a connection, or a data source or sink.  A device
that forwards a packet has no need to define a socket, since its not sourcing or
sinking data, its just forwarding it.

> 
> When the forwarded packet arrived at its destination
> machine, is there any socket associated with the
> packet on the destination machine?
> 
Sure, at the originating host, and at the receiving host.
Neil
> Thanks again. 
> 
> Best Regards,
> Park Lee
> 
> 
> 		
> __________________________________ 
> Do you Yahoo!? 
> Plan great trips with Yahoo! Travel: Now over 17,000 guides!
> http://travel.yahoo.com/p-travelguide
> 

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
