From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Iproute2: update
Date: Tue, 29 Mar 2005 21:07:57 +0200
Message-ID: <20050329190757.GA7321@xi.wantstofly.org>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net> <20050321201128.GA10625@xi.wantstofly.org> <20050329100942.062a3ed5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050329100942.062a3ed5@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 10:09:42AM -0800, Stephen Hemminger wrote:

> > TABLESIZE is 16384, and some debug code shows that it's trying to
> > write one element past the end of the table:
> > 
> > 	setting table[16384] to 4.008800
> > 	setting table[16384] to 4.008850
> > 	[...]
> > 	setting table[16384] to 10.049950
> > 	setting table[16384] to 10.050000
> > 
> > I thought it was a floating point emulation bug at first, but it
> > also appears to do this on my x86.
> > 
> > We don't use table[16384] anyway, so this works:
> 
> I thought this was fixed in current versions because it allocates
> space for TABLESIZE+1 entries in the call to calloc.
> 
> 	table = calloc(sizeof(double), TABLESIZE+1);

I saw the problem with the FC3 version of iproute2.  The newest
announcement I had in my inbox was of the ss050112 version, so I
downloaded that, and saw that it still had the problem.  I didn't
see any announcements newer than that one so I assumed that that
was the latest version.  I see now that the version that came after
that indeed has that issue fixed, so sorry for the noise.


--L
