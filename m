From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] support for large number of network devices.
Date: Thu, 15 Jan 2004 09:52:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115095252.3641d126.shemminger@osdl.org>
References: <20040113154610.38f5934c.shemminger@osdl.org>
	<20040113155921.342db463.davem@redhat.com>
	<20040113161303.20f1159d.shemminger@osdl.org>
	<20040114071303.GG28521@waste.org>
	<20040114113734.4e9a0865.shemminger@osdl.org>
	<20040114121155.7dabd70e.davem@redhat.com>
	<20040114162411.08322247.shemminger@osdl.org>
	<20040115004631.2839c8b8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040115004631.2839c8b8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004 00:46:31 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Wed, 14 Jan 2004 16:24:11 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > This should make it match the existing semantics more exactly.
> > It will skip the false positive matchs from sscanf trailing chars
> > or blanks.
> 
> Ok, but... I thought we had decided to move towards the hashing based
> patch you said you had so we can kill two birds with one stone?
> 
> At least, that is the conclusion I thought we had arrived at.
> :-)

The right way is a combination of the two pass dev_alloc_name and hashing
the names.  Both work together
