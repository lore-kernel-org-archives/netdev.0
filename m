From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 13:33:01 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030610.084940.74727904.davem@redhat.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "ralph+d@istop.com" <ralph+d@istop.com>,
	"hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
	"xerox@foonet.net" <xerox@foonet.net>,
	"sim@netnation.com" <sim@netnation.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.084940.74727904.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

>    From: Ralph Doncaster <ralph@istop.com>
>    Date: Mon, 9 Jun 2003 20:32:48 -0400 (EDT)
>
>    Lastly from the software side Linux doesn't seem to have anything like
>    BSD's parameter to control user/system CPU sharing.  Once my CPU load
>    reaches 70-80%, I'd rather have some dropped packets than let the CPU hit
>    100% and end up with my BGP sessions drop.
>
> When packet (more specifically, software interrupt) processing
> reaches a certain level, we offload the work into process context.

That sounds good.  Is there a sysctl I can use to define "certain level"?

-Ralph

