From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Update tcp_tso_win_divisor sysctl information in
 ip-sysctl.txt
Date: Fri, 8 Oct 2004 11:20:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008112032.769b632e.davem@davemloft.net>
References: <1886784988.20041008141045@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Maciej Soltysiak <solt2@dns.toxicfilms.tv>
In-Reply-To: <1886784988.20041008141045@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Oct 2004 14:10:45 +0200
Maciej Soltysiak <solt2@dns.toxicfilms.tv> wrote:

> I noticed that newly added tcp_tso_win_divisor did not go
> with a description to ip-sysctl.txt
> 
> This patch updates this information.

The implementation isn't cast in stone yet, I still want to play
with including tp->max_window in the clamps somehow and I'll add
the docs after I'm doing experimenting with that.
