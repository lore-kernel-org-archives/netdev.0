From: Greg Banks <gnb@sgi.com>
Subject: Re: NAPI, e100, and system performance problem
Date: Tue, 19 Apr 2005 15:55:35 +1000
Message-ID: <20050419055535.GA12211@sgi.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408> <Pine.LNX.4.61.0504180943290.15052@linux.site> <1113855967.7436.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113855967.7436.39.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2005 at 04:26:07PM -0400, jamal wrote:
> On Mon, 2005-18-04 at 09:55 -0700, Arthur Kepner wrote:
> > I'll just chime in to say that I've seen similar behavior,
> > (but with a very different system.)
> 
> It would _help_ a great deal if people collect data and post.
> What was this other system? Was it running e100 as well? etc etc

http://marc.theaimsgroup.com/?l=linux-netdev&m=107183822710263&w=2

> > The problem with NAPI is (quoting a co-worker) that it
> > relies on an "accident of timing".
> > 
> 
> geez, that almost sounds like an insult. spank your coworker for me with
> something sharp (i hope s/he doesnt enjoy it)

No, thank you.  Maybe next time.

> How do you recognize when system resources are being poorly utilized?

An inordinate amount of CPU is being spent running around polling the
device instead of dealing with the packets in IP, TCP and NFS land.
By inordinate, we mean twice as much or more cpu% than a MIPS/Irix
box with slower CPUs.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
