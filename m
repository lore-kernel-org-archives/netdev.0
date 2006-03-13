From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 13 Mar 2006 15:22:42 -0500
Message-ID: <20060313202242.GC27761@kvack.org>
References: <200603130139.k2D1dpSQ021279@shell0.pdx.osdl.net> <20060312.180802.13404061.davem@davemloft.net> <200603132105.32794.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932439AbWCMU2J@vger.kernel.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
Content-Disposition: inline
In-Reply-To: <200603132105.32794.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2006 at 09:05:31PM +0100, Ingo Oeser wrote:
> From: Ingo Oeser <ioe-lkml@rameria.de>
> 
> Fold __scm_send() into scm_send() and remove that interface completly
> from the kernel.

Whoa, what are you doing here?  Uninlining scm_send() is a Bad Thing to do 
given that scm_send() is in the AF_UNIX hot path.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
