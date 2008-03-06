From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Thu, 6 Mar 2008 08:41:14 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803060840540.13012@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
 <47CFF9B7.5060803@trash.net> <Pine.LNX.4.64.0803061612290.4202@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, joe@perches.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934868AbYCFQlt@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0803061612290.4202@sbz-30.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Mar 2008, Pekka J Enberg wrote:

> Then ksize(p) will return the currently allocated size which is 32 bytes 
> when page size is 4 KB, and not 8 bytes. So it should be equivalent of 
> what the current code does.

True for SLAB. SLUB will actually allocate only 8 bytes.
