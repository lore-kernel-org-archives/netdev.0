From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 16:53:23 +0100
Message-ID: <20100113155323.GB24818@basil.fritz.box>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com> <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755955Ab0AMPxa@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B4DE887.6030602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2010 at 10:36:39AM -0500, William Allen Simpson wrote:
> Andi Kleen wrote:
>> It's difficult to benchmark this code, but did you check that the code 
>> shrinks after applying this patch at least?
>>
> Good question.  Only on a gross scale with ls -l.
>
> Before: 332612
> After:  332384

size is better.

>
> I've just spent an hour Googling and then trying to decipher the make file
> looking for a standard way to generate the -S (.s output), but no joy.
>
> What make command would you suggest to get the interleaved asm?

make path/to/file.lst

(or .S -- you might need uptodate binutils if the lst listing is messed up)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
