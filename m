From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix secure tcp sequence number generation
Date: Tue, 5 Oct 2004 14:31:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005143131.6babd2c7.davem@davemloft.net>
References: <415EEF0E.3080808@colorfullife.com>
	<20041005132724.6a913c48.davem@davemloft.net>
	<41630713.2080606@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <41630713.2080606@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Oct 2004 22:41:55 +0200
Manfred Spraul <manfred@colorfullife.com> wrote:

> Right patch but wrong description, sorry:
> I've recycled the description from the previous patch and that one used 
> get_seconds() in rekey_seq_generator(). Now rekey_seq_generator() 
> doesn't access the time at all, that's done within schedule_delayed_work().

Great, I'll apply then.

Thanks.
