From: Nish Aravamudan <nish.aravamudan@gmail.com>
Subject: Re: how netfilter handles fragmented packets
Date: Sun, 21 Nov 2004 09:37:18 -0800
Message-ID: <29495f1d04112109372bb8ebe4@mail.gmail.com>
References: <20041121153154.85910.qmail@web41403.mail.yahoo.com>
	 <Pine.LNX.4.53.0411211714530.18608@yvahk01.tjqt.qr>
Reply-To: Nish Aravamudan <nish.aravamudan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cranium2003 <cranium2003@yahoo.com>, kernelnewbies@nl.linux.org,
	linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261655AbUKURhY@vger.kernel.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
In-Reply-To: <Pine.LNX.4.53.0411211714530.18608@yvahk01.tjqt.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004 17:15:12 +0100 (MET), Jan Engelhardt
<jengelh@linux01.gwdg.de> wrote:
> >hello,
> >          In ip_output.c file ip_fragmet function when
> >create a new fragmented packet given to output(skb)
> >function. i want to know which function are actually
> >called by output(skb)?
> 
> use stack_dump() (or was it dump_stack()?)

dump_stack(), if you want to dump the current process' stack context.

-Nish
