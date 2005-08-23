From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] AX.25 UID fixes
Date: Tue, 23 Aug 2005 09:24:43 -0700 (PDT)
Message-ID: <20050823.092443.42164438.davem__37140.088939532$1124814524$gmane$org@davemloft.net>
References: <20050822111038.GA7545@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@linux-mips.org, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org
In-Reply-To: <20050822111038.GA7545@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 22 Aug 2005 12:10:38 +0100

>  o Brown paperbag bug - ax25_findbyuid() was always returning a NULL pointer
>    as the result.  Breaks ROSE completly and AX.25 if UID policy set to deny.
> 
>  o While the list structure of AX.25's UID to callsign mapping table was
>    properly protected by a spinlock, it's elements were not refcounted
>    resulting in a race between removal and usage of an element.
> 
> Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

Applied, thanks Ralf.
