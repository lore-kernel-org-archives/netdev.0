From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Sun, 8 Feb 2004 09:07:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402080900450.25152@localhost.localdomain>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
 <20040206194518.56787717.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040206194518.56787717.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004, David S. Miller wrote:

> On Fri, 6 Feb 2004 17:24:32 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> > Please do a
> > 	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
> > to get the following udpates to SCTP on top of linux 2.6.2
>
> Pulled, but.
>
> > - Updated the default max socket receive buffer to 64K from 32K and also
> >   added sysctl variables to change sctp socket send/receive buffers.
>
> Why do you use specialized SCTP rmem/wmem values and not the globally
> sysctl's ones we have for sockets already?

Dave,

I guess i was influenced by the TCP specific tcp_rmem/tcp_wmem. But TCP
seems to be using them as a vector of 3 values and tuning the buffer sizes
dynamically based on these values.
As of now, SCTP doesn't do any tuning dynamically so i could have used the
core rmem_default/wmem_default.

Do you want me to remove the specialized SCTP sysctl's?

Thanks
Sridhar
