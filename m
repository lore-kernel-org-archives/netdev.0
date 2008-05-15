From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 14:21:54 +0100
Message-ID: <20080515142154.0595e475@core>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Peterson <cpeterso@cpeterso.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759482AbYEONdV@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 May 2008 00:11:10 -0700 (PDT)
Chris Peterson <cpeterso@cpeterso.com> wrote:

> 
> I know Jeff Garzik says he's not interested in an anti-entropy pogrom for existing net drivers, but here is the patch if anyone else is interested..? :)
> 
> Only 12 net drivers are affected, the last of the theoretically-exploitable network entropy.

Looks fine to me. If Jeff doesn't want to touch them then send them
direct to Andrew/Linus.

A more interesting alternative might be to mark things like network
drivers with a new flag say IRQF_SAMPLE_DUBIOUS so that users can be
given a switch to enable/disable their use depending upon the environment.

Alan
