From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Sun, 02 Oct 2011 07:47:12 -0700 (PDT)
Message-ID: <4cd3c66e-b0f1-440c-a170-a1df7d6a2691@tahiti.vyatta.com>
References: <1317540066.3802.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, starlight@binnacle.cx
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317540066.3802.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try disabling PCI DMA remapping. The additional overhead of setting
up IO mapping can be a performance buzz kill. Try CONGIG_DMAR=n
