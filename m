From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 1/5] ipcomp_tunnel_create doesn't set tunnel state
Date: Tue, 13 Jan 2004 23:20:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113232009.008a57a7.davem@redhat.com>
References: <20040110121134.08481951.davem@redhat.com>
	<Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 13:21:19 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> ipcomp_tunnel_create doesn't set x->km.state to XFRM_STATE_DEAD. This can lead
> to the BUG_TRAP in __xfrm_state_destroy when xfrm_state_put() finds this is
> the last reference. This was reported as one of the symptoms of [Bug 1754]
> some time back.

Patch applied, thanks.
