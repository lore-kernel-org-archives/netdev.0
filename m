From: "David S. Miller" <davem@davemloft.net>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Mon, 6 Dec 2004 13:48:49 -0800
Message-ID: <20041206134849.498bfc93.davem@davemloft.net>
References: <20041206205305.GA11970@soohrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261666AbULFVuN@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041206205305.GA11970@soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Dec 2004 21:53:05 +0100
Karsten Desler <kdesler@soohrt.org> wrote:

>  20017 ipt_do_table                              24.0589

It's spending nearly half of it's time in iptables.
Try to consolidate your rules if possible.  This is the
part of netfilter that really doesn't scale well at all.
