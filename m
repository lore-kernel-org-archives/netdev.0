From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Fri, 6 Feb 2004 19:45:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206194518.56787717.davem@redhat.com>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004 17:24:32 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Please do a
> 	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
> to get the following udpates to SCTP on top of linux 2.6.2

Pulled, but.

> - Updated the default max socket receive buffer to 64K from 32K and also
>   added sysctl variables to change sctp socket send/receive buffers.

Why do you use specialized SCTP rmem/wmem values and not the globally
sysctl's ones we have for sockets already?
