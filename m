From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 11:26:11 -0800
Message-ID: <20050223112611.60561121.davem@davemloft.net>
References: <052Q0TU11@server5.heliogroup.fr>
	<200502231835.j1NIZX2T020606@uni07mr.unity.ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hubert.tonneau@fullpliant.org, shemminger@osdl.org, cliffw@osdl.org,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: "Injong Rhee" <rhee@eos.ncsu.edu>
In-Reply-To: <200502231835.j1NIZX2T020606@uni07mr.unity.ncsu.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005 13:37:35 -0500
"Injong Rhee" <rhee@eos.ncsu.edu> wrote:

> 
> 
> > -----Original Message-----
> > From: Hubert Tonneau [mailto:hubert.tonneau@fullpliant.org]
> > Sent: Tuesday, February 22, 2005 5:23 PM
> > 2.6.9 to 100 Mbps connected MacOSX: 15 seconds (for roughly 100 MB
> > or data)
> > 2.6.9 to gigabit connected MacOSX: 5 seconds
> > 2.6.10-ac11 to 100 Mbps connected MacOSX: 325 seconds
> > 2.6.10-ac11 to gigabit connected MacOSX: 5 seconds
> > 2.6.10-ac11+BIC to 100 Mbps connected MacOSX: 620 seconds
> > 2.6.10-ac11+BIC to gigabit connected MacOSX: 5 seconds
> 
> Another way to test whether this is related to the os or bic
> implementation is to test it with our bic patch 1.1. + Linux 2.4. It
> will tell whether the original implementation of BIC has something to
> do with the performance with respect to MacOS. 

I don't think BIC has much to do with this problem.  MacOS-X does delayed
ACKs until a PSH is seen and this kills performance if we don't PSH often
enough.
