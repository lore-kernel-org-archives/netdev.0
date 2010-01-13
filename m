From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 10:36:39 -0500
Message-ID: <4B4DE887.6030602@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com> <20100113115617.GA24818@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755300Ab0AMPgo@vger.kernel.org>
In-Reply-To: <20100113115617.GA24818@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> It's difficult to benchmark this code, but did you check that the code 
> shrinks after applying this patch at least?
> 
Good question.  Only on a gross scale with ls -l.

Before: 332612
After:  332384

I've just spent an hour Googling and then trying to decipher the make file
looking for a standard way to generate the -S (.s output), but no joy.

What make command would you suggest to get the interleaved asm?
