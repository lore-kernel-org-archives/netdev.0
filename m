From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 11:17:19 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225111719.4b99403a.davem@redhat.com>
References: <20040225101225.496d02d0.davem@redhat.com>
	<Pine.LNX.4.44.0402251017510.3691-100000@dyn319495.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kashyapv <kashyapv@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0402251017510.3691-100000@dyn319495.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 11:07:48 -0800 (PST)
kashyapv <kashyapv@us.ibm.com> wrote:

> Also, an in-kernel solution allows administrative control and tuning 
> without affecting the applications at all. The administrator can as per 
> the policy (which may change over time) modify the proportions using another
> interface. Otherwise, each application must provide a way to manage/modify 
> its scheduler.

Since all of the classification we're suggesting is via the kernel, the
administrator has the same kinds of controls and it is also without any
application modifications.

We're saying, to classify packets so that they get prioritized however you
would have prioritized things in the accept queue (ie. mark SYN packets
with address X as having priority Y).  The let the packet scheduler or
netfilter take care of the rest.
