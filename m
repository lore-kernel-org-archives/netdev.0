From: "Dan A. Dickey" <dan.dickey@savvis.net>
Subject: Re: TCP Hang (or close to it):  Windows XP -> Linux (w/tcp_bic)
Date: Fri, 29 Oct 2004 13:21:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410291321.25723.dan.dickey@savvis.net>
References: <200410290925.48955.dan.dickey@savvis.net> <Pine.LNX.4.58.0410291005100.3323@w-sridhar.beaverton.ibm.com> <20041029110019.4f175979.davem@davemloft.net>
Reply-To: dan.dickey@savvis.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041029110019.4f175979.davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 29 October 2004 13:00, David S. Miller wrote:
> On Fri, 29 Oct 2004 10:10:42 -0700 (PDT)
>
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> > This looks like the same TCP window overflow problem in 2.6.7
> > that came up a couple of days back.
> >
> > See the thread
> >  http://marc.theaimsgroup.com/?t=109887532400001&r=1&w=2
> > and the patch posted by davem.
>
> Yes, and BTW for the original poster, BIC only effects sender
> behavior whereas in your test case the Linux system with BIC
> enabled is the receiver.

That's a good point.  I was concerned that it might be
playing a role in what window size got sent back to
the sending machine.  Glad to hear it's not a worry.
BTW - any idea if tcp_bic would be easily modified
to be configurable on a per interface basis?  We typically
have a 100Mb interface on a LAN; and another 100Mb
interface going out to a WAN (DS3 or E3).
We're using tcp_bic to get near 95+% utilization of the
WAN connection; but I don't think we need it on the LAN,
and in some situations it may interfere... or, is this not
a concern?  Thanks again all.

Sridhar,
thank's for the pointer.

I'll be updating to 2.6.9 and will let you know the
results of my testing.
 -Dan

-- 
Dan A. Dickey
dan.dickey@savvis.net

SAVVIS
Transforming Information Technology
