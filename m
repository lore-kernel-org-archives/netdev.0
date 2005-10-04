From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Tue, 04 Oct 2005 19:01:41 +0200
Message-ID: <4342B575.9090709@trash.net>
References: <432EF0C5.5090908@cosmosbay.com>	<Pine.LNX.4.61.0509280219110.25500@filer.marasystems.com>	<20050928083240.GP4168@sunbeam.de.gnumonks.org> <200509281037.03185.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	Henrik Nordstrom <hno@marasystems.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030239AbVJEQhs@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200509281037.03185.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> In a sense it's even getting worse: For example us losing the CONFIG
> option to disable local conntrack (Patrick has disabled it some time ago 
> without even a comment why he did it) has a really bad impact in some cases.

It was necessary to correctly handle locally generated ICMP errors.
