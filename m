From: bert hubert <ahu@ds9a.nl>
Subject: Re: analysis of TCP window size issues still around - several reports / SACK involved?
Date: Tue, 6 Jul 2004 22:27:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706202708.GA1385@outpost.ds9a.nl>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org> <20040629222751.392f0a82.davem@redhat.com> <20040630152750.2d01ca51@dell_ss3.pdx.osdl.net> <20040630153049.3ca25b76.davem@redhat.com> <20040701133738.301b9e46@dell_ss3.pdx.osdl.net> <20040701140406.62dfbc2a.davem@redhat.com> <20040702013225.GA24707@conectiva.com.br> <20040706093503.GA8147@outpost.ds9a.nl> <20040706131955.3a3c6c8b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@conectiva.com.br, shemminger@osdl.org, netdev@oss.sgi.com,
        alessandro.suardi@oracle.com, phyprabab@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040706131955.3a3c6c8b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 06, 2004 at 01:19:55PM -0700, David S. Miller wrote:

> rather it do this, so that diagnosing dumps are easier.  If tcpdump
> tries to be too clever, scaling the window, then I might end up
> chasing down a tcpdump bug rather than a TCP one :-)

True - it might want to print '43 (*128=5706)' or something like that.

> What would be more interesting is to get the tcpdump trace from the
> other side of this connection.  This is crucial, as it will show how
> and in what way exactly the window scale options and/or window fields
> are being edited by a firewall or other device and thus causing
> the problems.

I have an appointment with Alessandro tomorrow evening at 11PM CEST to do
just that.

It sounds like window scaling may become yet another ECN...

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
