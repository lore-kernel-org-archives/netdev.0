From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Mon, 9 Feb 2004 12:41:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209124145.48de8d55.davem@redhat.com>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
	<20040206194518.56787717.davem@redhat.com>
	<Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>
	<4027EECA.9000705@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <4027EECA.9000705@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 09 Feb 2004 12:34:18 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Sorry to pitch in on this so late - and I'm not suggesting
> this was not the right thing to do here, but I feel that
> having the per-protocol globals (as we do for TCP) is a
> good thing, as then you don't affect all (raw, udp..)
> traffic on the system just because someone is tuning
> for SCTP, etc.

I understand.

But there was no known reason to tweak things for SCTP.
If one wanted to adjust things system wide there was no
way for it to apply to SCTP too.

Also, the TCP controls are not as they would seem.  They don't
directly effect things like the sysctl*{rmem,wmem} stuff does,
rather it influences the dynamic socket buffer sizing which
TCP does.
