From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] enhanced version of net_random()
Date: Thu, 12 Aug 2004 12:48:54 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040812124854.646f1936.davem@redhat.com>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, tytso@mit.edu, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268680AbUHLTuG@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Thu, 12 Aug 2004 10:48:35 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Here is a proposed alternative to use a longer period PRNG for net_random().
> The choice of TT800 was because it was freely available, had a long period,
> was fast and relatively small footprint. The existing net_random() was not
> really thread safe, but was immune to thread corruption. 

Any chance of a version that doesn't grab a global lock and
disable interrupts every call? :(
