From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 26 Jun 2006 07:23:42 +0200
Message-ID: <200606260723.43209.ak@suse.de>
References: <4492D5D3.4000303@atmos.washington.edu> <200606191724.31305.ak@suse.de> <20060625222243.GJ13255@w.ods.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932389AbWFZFXw@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
In-Reply-To: <20060625222243.GJ13255@w.ods.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I encountered the same problem on a dual core opteron equipped with a
> broadcom NIC (tg3) under 2.4. It could receive 1 Mpps when using TSC
> as the clock source, but the time jumped back and forth, so I changed
> it to 'notsc', then the performance dropped dramatically to around the
> same value as above with one CPU saturated. I suspect that the clock
> precision is needed by the tg3 driver to correctly decide to switch to
> polling mode, but unfortunately, the performance drop rendered the
> solution so much unusable that I finally decided to use it only in
> uniprocessor with TSC enabled.

2.6 is more clever at this than 2.4. In particular it does the timestamp
for each packet only when actually needed, which is relativelt rare.

Old experiences do not always apply to new kernels.

-Andi
