From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Mon, 8 Mar 2004 15:37:23 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040308153723.21244593.davem@redhat.com>
References: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net>
	<20040308212156.GE26401@wotan.suse.de>
	<20040308133009.1e068199@dell_ss3.pdx.osdl.net>
	<20040308213646.GH26401@wotan.suse.de>
	<20040308134542.62320cae@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040308134542.62320cae@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004 13:45:42 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> There is redundancy in the control block now, perhaps that could be squished,
> fields that are only used during connection setup or if other things are true.
> Also there seems to be several one byte wide booleans that could be collapsed
> to bits.

That's right, and this is where we should concentrate our efforts.
The things that are truly unique in the TCB for westwood and vegas
are actually quite small.
