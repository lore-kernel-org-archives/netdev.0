From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/4) packet scheduler bad TDIFF_SAFE in csz
Date: Tue, 29 Jun 2004 15:28:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629152822.4fa2e1c4.davem@redhat.com>
References: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
	<20040629144506.0649d217.davem@redhat.com>
	<1088547756.1040.5.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088547756.1040.5.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Jun 2004 18:22:37 -0400
jamal <hadi@cyberus.ca> wrote:

> That scheduler is only a relic.
> Nobody uses it ;-> Check the cofig help.
> Pretty sure if you study it youll find a lot more bugs.

Right, but it is good that we fix the obvious ones when
we can.  Stephen's fix resulted in being able to simplify
some PSCHED_* macros significantly.
