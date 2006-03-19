From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [AX.25] Fix potencial memory hole.
Date: Sun, 19 Mar 2006 13:20:18 -0800 (PST)
Message-ID: <20060319.132018.80403704.davem@davemloft.net>
References: <20060319124246.GA6261@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: ralf@linux-mips.org
In-Reply-To: <20060319124246.GA6261@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Date: Sun, 19 Mar 2006 12:42:46 +0000

> If the AX.25 dialect chosen by the sysadmin is set to DAMA master / 3
> (or DAMA slave / 2, if CONFIG_AX25_DAMA_SLAVE=n) ax25_kick() will fall
> through the switch statement without calling ax25_send_iframe() or any
> other function that would eventually free skbn thus leaking the packet.
> 
> Fix by restricting the sysctl inferface to allow only actually supported
> AX.25 dialects.
> 
> The system administration mistake needed for this to happen is rather
> unlikely, so this is an uncritical hole.
> 
> Coverity #651.
> 
> Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

Applied, thanks a lot Ralf.
