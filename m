From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] tcp: input header length, prediction, and timestamp bugs
Date: Fri, 15 Jan 2010 14:12:28 -0500
Message-ID: <4B50BE1C.3070409@gmail.com>
References: <4B49C2D0.1070704@gmail.com> <4B5078BB.40306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758059Ab0AOTMd@vger.kernel.org>
In-Reply-To: <4B5078BB.40306@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson wrote:
> Finally, don't use TCPOLEN_MD5SIG_ALIGNED in the tcp_minisock.c
> last_seg_size calculations. It's not used in all other places, and may
> result in a too short estimate.
> 
> Instead, use the same calculations as tp->advmss in tcp_input.c.
> 
This part really shouldn't have been included in this patch, as it
depends on similar changes to tcp_output.c.  My mistake cutting the
patches apart from the bigger testing patch.

I'll send a new version promptly.
