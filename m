From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] convering bonding driver /proc interface to seq_file
Date: Mon, 25 Aug 2003 12:27:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030825122703.47cefa5b.shemminger@osdl.org>
References: <E791C176A6139242A988ABA8B3D9B38A014C94CD@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "James Morris" <jmorris@intercode.com.au>,
   <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C94CD@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Aug 2003 21:43:24 +0300
"Hen, Shmulik" <shmulik.hen@intel.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@osdl.org]
> > Sent: Monday, August 25, 2003 6:45 PM
> > To: James Morris
> > Cc: Hen, Shmulik; Chad Tindel; Jay Vosburgh; David S. Miller; 
> > Jeff Garzik; bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> > Subject: Re: [PATCH] convering bonding driver /proc interface 
> > to seq_file
> > 
> > Using a pointer with seq_file was really easy.
> [snip]
> > 		seq->private = PDE(inode)->data;
> 
> Yes, but PDE(inode) does not exist in 2.4 yet, and we wanted
> to achieve compatibility between bonding in 2.6 and 2.4 first
> so we may then update 2.6 bonding which is too far behind
> what's in 2.4 bonding. Once this is done it will be possible
> to develop on 2.6, and back port into 2.4 from time to time.
> 
> 
> 	Shmulik.

#ifndef PDE
#define PDE(i) ((struct proc_dir_entry *)(i)->u.generic_ip)
#endif
