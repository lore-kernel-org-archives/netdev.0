From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Mon, 8 Mar 2004 15:31:22 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040308153122.5829617f.davem@redhat.com>
References: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net>
	<20040308212156.GE26401@wotan.suse.de>
	<20040308133009.1e068199@dell_ss3.pdx.osdl.net>
	<20040308213646.GH26401@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, ak@suse.de, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040308213646.GH26401@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004 22:36:46 +0100
Andi Kleen <ak@suse.de> wrote:

> > CONFIG options are of no use vendors who need to ship binary kernels.
> 
> I can well see a vendor trading scalability for experimental non standard TCP 
> algorithms that tend to be disabled anyways.

I explicitly removed the CONFIG_ options guarding the westwood stuff
when I added it to the tree.  I want people to use this stuff, and
I don't want them to have to enable weird config options just to do
so.
