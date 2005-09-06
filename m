From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.13 2/2] 3c59x: add option for using memory-mapped
 PCI I/O resources
Date: Tue, 6 Sep 2005 15:15:46 -0700
Message-ID: <20050906151546.4d5ed4db.akpm@osdl.org>
References: <20050906204147.GC20145@tuxdriver.com>
	<20050906204400.GD20145@tuxdriver.com>
	<20050906205429.GA19319@infradead.org>
	<20050906140414.40b65253.akpm@osdl.org>
	<20050906220922.GA26003@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751038AbVIFWRw@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20050906220922.GA26003@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"John W. Linville" <linville@tuxdriver.com> wrote:
>
> I fully intend to have have a flag in the private data set based on
>  the PCI ID when I accumulate some data on which devices support this
>  and which don't.  So far I've only got a short list...  Do you think
>  such a flag should be based on which ones work, or which ones break?

The ones which are known to work.

Bear in mind that this is an old, messy and relatively stable driver which
handles a huge number of different NICs.   Caution is the rule here.
