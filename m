From: Andrew Morton <akpm@osdl.org>
Subject: Re: [2.6.15] running tcpdump on 3c905b causes freeze (reproducable)
Date: Mon, 9 Jan 2006 04:11:14 -0800
Message-ID: <20060109041114.6e797a9b.akpm@osdl.org>
References: <20060108114305.GA32425@vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932276AbWAIMLe@vger.kernel.org>
To: Folkert van Heusden <folkert@vanheusden.com>
In-Reply-To: <20060108114305.GA32425@vanheusden.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folkert van Heusden <folkert@vanheusden.com> wrote:
>
> My system freezes (crashes) when I run tcpdump on the interface
>  connected to a 3c905b card.

Works for me with a 3c980-TX.  I can dig out a 905b.

Please send the exact commands which you're using to demonstrate this -
sufficient info for me to get as close as possible to what you're doing.

Have you tried enabling the NMI watchdog?  Enable CONFIG_X86_LOCAL_APIC and
boot with `nmi_watchdog=1' on the command line, make sure that the NMI line
of /proc/interrupts is incrementing.
