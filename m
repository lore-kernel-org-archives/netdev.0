From: John Heffner <jheffner@psc.edu>
Subject: Re: net-AIO and real-time TCP (blue sky research)
Date: Thu, 12 Aug 2004 14:11:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0408121402090.5007-100000@dexter.psc.edu>
References: <20040811214044.U28020@almesberger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
        Suparna Bhattacharya <suparna@in.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
In-Reply-To: <20040811214044.U28020@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Aug 2004, Werner Almesberger wrote:

> Sridhar Samudrala wrote:
> > Your AIO-TCP looks pretty similar to the partial reliablity extension to
> > SCTP that allows an SCTP endpoint to signal to its peer that it is no longer
> > going to retransmit certain messages and should skip past those messages.
>
> Damn, so it's not such a crazy idea after all :-)

Perhaps not for SCTP.  I'd love to see a good AIO API for TCP, but if what
you are describing is implemented, the resulting protocol would be
something other than TCP.  There are some RDDP people talking about
similar things, and it is quite controversial within the IETF.

It might be easier to focus on SCTP.  This is what it was designed for.

  -John
