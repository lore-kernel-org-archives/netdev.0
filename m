From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 4/5] xfrm_state_construct doesn't set tunnel state
Date: Tue, 13 Jan 2004 23:25:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113232524.6ca5b0fe.davem@redhat.com>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
	<Pine.LNX.4.44.0401131323410.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401131323410.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 13:24:23 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> xfrm_state_construct doesn't set x->km.state to XFRM_STATE_DEAD. This can lead
> to the BUG_TRAP in __xfrm_state_destroy when xfrm_state_put() finds this is
> the last reference. This was reported as one of the symptoms of [Bug 1754]
> some time back.

Smells just like the nearly identical case in ipcomp :-)

Patch applied, thanks.
