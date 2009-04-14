From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 14 Apr 2009 14:53:42 -0700
Message-ID: <20090414215342.GB9877@ovro.caltech.edu>
References: <20090224000002.GA578@ovro.caltech.edu>
	<fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2009 at 02:28:26PM -0600, Grant Likely wrote:
> On Mon, Feb 23, 2009 at 6:00 PM, Ira Snyder <iws@ovro.caltech.edu> wrote:
> > This adds support to Linux for using virtio between two computers linked by
> > a PCI interface. This allows the use of virtio_net to create a familiar,
> > fast interface for communication. It should be possible to use other virtio
> > devices in the future, but this has not been tested.
> 
> Hey Ira,
> 
> I like this a lot.  I need to do much the same thing on one of my
> platforms, so I'm going to use your patch as my starting point.  Have
> you made many changes since you posted this version of your patch?
> I'd like to collaborate on the development and help to get it
> mainlined.
> 

This would be great. I'd really appreciate the help. I haven't had time
to make any changes since I last posted the patch. I started work on
converting all of the usage of struct vop_loc_* to just use the on-wire
structures, but I didn't get very far before other work got in the way.

> In my case I've got an MPC5200 as the 'host' and a Xilinx Virtex
> (ppc440) as the 'client'.  I intend set aside a region of the Xilinx
> Virtex's memory space for the shared queues.  I'm starting work on it
> now, and I'll provide you with feedback and/or patches as I make
> progress.
> 

I'm looking forward to seeing your implementation. If you have any
questions, I'd be happy to attempt to answer them :)

Ira
