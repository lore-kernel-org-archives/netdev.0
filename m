From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Tue, 22 Feb 2005 23:38:32 +0000
Message-ID: <421BC278.90400@ev-en.org>
References: <050QTJA12@server5.heliogroup.fr>	<20050209105909.17da40a9@dxpl.pdx.osdl.net> <20050222135046.23f7ec7d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Tonneau <hubert.tonneau@fullpliant.org>,
        cliff white <cliffw@osdl.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Yee-Ting Li <yee-ting.li@nuim.ie>, Doug Leith <doug.leith@nuim.ie>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050222135046.23f7ec7d@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch which was extracted from BIC TCP 1.1 compensates
> for systems (like MaxOSX) that don't ACK every other packet.
> It has no impact for normal transfers, but might help with problems
> with Mac like Hubert found.

We have a version of ABC (Appropriate Byte Counting) implementation of 
RFC 3465, which we hope to submit soon for inclusion in the kernel which 
should be a more appropriate solution for this. The RFC is a well 
defined standard whereas this patch has not received any reviewing by 
the networking community.

This solution is just a band-aid for only one congestion control, as 
opposed to a generic solution. It is also prone to make BIC more 
aggressive according to our testing.

I'll try to post our ABC patch tomorrow, time permitting.

One thing to note is that accounting for delayed acking is not an overly 
important feature, from our testing it only speeds up convergence by a 
small factor and doesn't change the correctness of the algorithms.

Baruch
