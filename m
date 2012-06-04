From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 1/3] Add missing can.h
Date: Mon, 4 Jun 2012 12:10:32 -0700
Message-ID: <20120604121032.029dee44@nehalam.linuxnetplumber.net>
References: <1338826149-11604-1-git-send-email-lisovy@gmail.com>
	<1338826149-11604-2-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1338826149-11604-2-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  4 Jun 2012 18:09:07 +0200
Rostislav Lisovy <lisovy@gmail.com> wrote:

> This header file is slightly modified version copied from
> Linux kernel v. 3.3. It contains defines necessary for working
> with AF_CAN packets.
> 
> Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>

Ok, but I will put in can.h but it will be done by copying the result
of the kernel 'make headers_install' which does the standard
removal of #ifdef kernel pieces. In iproute2, all kernel headers
used should come from this process.
