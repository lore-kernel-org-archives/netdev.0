From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Tue, 22 Feb 2005 16:58:02 -0800
Message-ID: <20050222165802.0dc2d333@dxpl.pdx.osdl.net>
References: <052Q0TU11@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cliff white <cliffw@osdl.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>,
        "David S. Miller"
 <davem@davemloft.net>
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>
In-Reply-To: <052Q0TU11@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Feb 2005 22:22:42 GMT
Hubert Tonneau <hubert.tonneau@fullpliant.org> wrote:

> Stephen Hemminger wrote:
> >
> > This patch which was extracted from BIC TCP 1.1 compensates
> > for systems (like MaxOSX) that don't ACK every other packet.
> > It has no impact for normal transfers, but might help with problems
> > with Mac like Hubert found.
> 
> No, it's even worse.
> 
> 2.6.9 to 100 Mbps connected MacOSX: 15 seconds (for roughly 100 MB or data)
> 2.6.9 to gigabit connected MacOSX: 5 seconds
> 2.6.10-ac11 to 100 Mbps connected MacOSX: 325 seconds
> 2.6.10-ac11 to gigabit connected MacOSX: 5 seconds
> 2.6.10-ac11+BIC to 100 Mbps connected MacOSX: 620 seconds
> 2.6.10-ac11+BIC to gigabit connected MacOSX: 5 seconds

Thanks, that is really interesting...
