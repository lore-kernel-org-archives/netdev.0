From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 5 Oct 2005 18:53:31 +0200
Message-ID: <200510051853.32196.ak@suse.de>
References: <432EF0C5.5090908@cosmosbay.com> <200509281037.03185.ak@suse.de> <4342B575.9090709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	Henrik Nordstrom <hno@marasystems.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030250AbVJEQ53@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4342B575.9090709@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 October 2005 19:01, Patrick McHardy wrote:
> Andi Kleen wrote:
> > In a sense it's even getting worse: For example us losing the CONFIG
> > option to disable local conntrack (Patrick has disabled it some time ago
> > without even a comment why he did it) has a really bad impact in some
> > cases.
>
> It was necessary to correctly handle locally generated ICMP errors.

Well you most likely wrecked local performance then when it's enabled.

-Andi
