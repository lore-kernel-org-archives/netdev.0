From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/5] Bad dereference of xfrm_state in pf_key
Date: Tue, 13 Jan 2004 23:21:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113232137.463554c9.davem@redhat.com>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
	<Pine.LNX.4.44.0401131321310.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401131321310.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 13:22:36 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> In pfkey_get(), the xfrm_state is dereferenced after it is dropped,
> which could lead to dereferencing freed memory. This can also be done
> by dropping the reference before the pfkey_broadcast() and in the IS_ERR
> case.

Obviously correct, patch applied thanks.
