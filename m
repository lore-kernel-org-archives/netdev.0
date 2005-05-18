From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Wed, 18 May 2005 15:19:34 +0200
Message-ID: <m1oeb86595.fsf@muc.de>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	<20050517190343.2e57fdd7.akpm@osdl.org>
	<Pine.LNX.4.62.0505171941340.21153@graphe.net>
	<20050517.195703.104034854.davem@davemloft.net>
	<Pine.LNX.4.62.0505172125210.22920@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261762AbVERNTz@vger.kernel.org>
To: Christoph Lameter <christoph@lameter.com>
In-Reply-To: <Pine.LNX.4.62.0505172125210.22920@graphe.net> (Christoph
 Lameter's message of "Tue, 17 May 2005 21:27:48 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> writes:

> On Tue, 17 May 2005, David S. Miller wrote:
>
>> > Because physically contiguous memory is usually better than virtually 
>> > contiguous memory? Any reason that physically contiguous memory will 
>> > break the driver?
>> 
>> The issue is whether size can end up being too large for
>> kmalloc() to satisfy, whereas vmalloc() would be able to
>> handle it.
>
> Oww.. We need a NUMA aware vmalloc for this?  

You can do that already by just changing process NUMA policy temporarily
while calling vmalloc.

-Andi
