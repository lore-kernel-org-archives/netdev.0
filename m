From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] rearrange frto field to save space.
Date: Wed, 21 Apr 2004 17:38:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421173821.4ec5c5c6.davem@redhat.com>
References: <20040420155738.4146b5bb.davem@redhat.com>
	<20040421111032.0705b605@dell_ss3.pdx.osdl.net>
	<1082592912.11328.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1082592912.11328.0.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 Apr 2004 17:15:12 -0700
Joe Perches <joe@perches.com> wrote:

> On Wed, 2004-04-21 at 11:10, Stephen Hemminger wrote:
> > +	__u8	unused_pad;
> 
> There's no real reason that I can see to have padding here.

SO that the next person adding member to this struct
know it exists.
