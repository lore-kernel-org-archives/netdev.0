From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TCP's reaction to soft errors
Date: Sun, 3 Oct 2004 14:09:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003140917.48cd6069.davem@davemloft.net>
References: <4.3.2.7.2.20040915112853.00cf9980@mail.daleclick.com>
	<4.3.2.7.2.20040915112853.00cf9980@mail.daleclick.com>
	<4.3.2.7.2.20041003105509.00e33650@pop.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Fernando Gont <fernando@gont.com.ar>
In-Reply-To: <4.3.2.7.2.20041003105509.00e33650@pop.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 03 Oct 2004 10:57:36 -0300
Fernando Gont <fernando@gont.com.ar> wrote:

> At 15:13 01/10/2004 -0700, David S. Miller wrote:
> 
> > > The draft proposes to change TCP's reaction to soft errors so that
> > > connections that are in the SYN-SENT or SYN-RECEIVED states are aborted
> > > upon receipt of an ICMP error message that indicates a soft error.
> >
> >I have verified that Linux behaves in a way compliant to this
> >proposal.  No changes are necessary.
> 
> Great! Thanks for your confirmation.
> BTW, do you have any record of how long Linux has been behaving this way? 
> (I'd like to include this information in the draft).

Even 2.0.x kernels behave this way.  Others are welcome to
search back even further :-)
