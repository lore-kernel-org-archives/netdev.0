From: Coywolf Qi Hunt <coywolf@gmail.com>
Subject: Re: [PATCH] sys_sendmsg() alignment bug fix
Date: Tue, 27 Sep 2005 11:40:38 +0800
Message-ID: <2cd57c90050926204022fb22ca@mail.gmail.com>
References: <1127764921.6529.60.camel@tdi>
Reply-To: Coywolf Qi Hunt <coywolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750830AbVI0Dkm@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
In-Reply-To: <1127764921.6529.60.camel@tdi>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/27/05, Alex Williamson <alex.williamson@hp.com> wrote:
>    The patch below adds an alignment attribute to the buffer used in
> sys_sendmsg().  This eliminates an unaligned access warning on ia64.

Is this a warning fix or bug fix?
--
Coywolf Qi Hunt
http://sosdg.org/~coywolf/
