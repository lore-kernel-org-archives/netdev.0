From: Olaf Kirch <okir@suse.de>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on a Linux machine
Date: Tue, 11 May 2004 22:53:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040511205319.GB26049@suse.de>
References: <OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com> <40A12646.7080605@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@oss.sgi.com,
        snortwiz@hotmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <40A12646.7080605@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 11, 2004 at 12:15:18PM -0700, Nivedita Singhvi wrote:
> I think the only issue here is if an application that
> binds to an interface should see packets coming in
> from another - if that is what is happening here?.

Well, to bind to an interface you need to use SO_BINDTODEVICE.

Everything else is just another address. You can even assign an address
to the dummy device and as long as you create static arp entries,
pinging that address from other hosts will work.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 
