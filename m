From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 3/5] xfrm_lookup bugs
Date: Tue, 13 Jan 2004 23:23:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113232335.2236706f.davem@redhat.com>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
	<Pine.LNX.4.44.0401131322440.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401131322440.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 13:23:35 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> In xfrm_lookup, a couple of bugs :
> 	- the found or allocated xfrm_states are not passed correctly to
> 	  xfrm_bundle_create (and to the subsequent frees in case of create
> 	  failing) if the first xfrm_tmpl_resolve failed and the second one
> 	  succeeded.
> 	- error handling is wrong.

Looks fine, patch applied thanks.
