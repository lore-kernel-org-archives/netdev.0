From: Marc Ballarin <ballarin.marc@gmx.de>
Subject: Re: Regression: non-working WOL with r8169
Date: Sat, 8 Oct 2011 00:31:56 +0200
Message-ID: <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de>
	<20111007210017.GA27820@electric-eye.fr.zoreil.com>
	<20111007214200.GA28365@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:55457 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758737Ab1JGWb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 18:31:59 -0400
In-Reply-To: <20111007214200.GA28365@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Oct 2011 23:42:00 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

>...
> Can you tell if CONFIG_PM is set and how the computer was shutdown / halted ?

CONFIG_PM is set, but the way the system is shut down seems to be an issue indeed.

WOL works after echo mem > /sys/power/state (but then the system crashes, but this is 
a separate issue).

But it does not work after halt/shutdown -h now.
