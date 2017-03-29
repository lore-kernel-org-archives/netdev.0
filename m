From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] ezchip: nps_enet: check if napi has been completed
Date: Wed, 29 Mar 2017 14:41:40 -0700
Message-ID: <CANn89iJ1+7CrF=hJj-_pLWV+EDXxhUZGOL+3je6zjE8dJDcr=A@mail.gmail.com>
References: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
 <20170329.143014.2001816338079751776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 noamca@mellanox.com, Vladislav.Zakharov@synopsys.com,
 linux-snps-arc@lists.infradead.org, eladkan@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170329.143014.2001816338079751776.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 2:30 PM, David Miller <davem@davemloft.net> wrote:
Signed-off-by: Vlad Zakharov <vzakhar@synopsys.com>
>
> Applied.
>
> Eric, if this is really required now, we have 148 broken drivers still.

Piece of cake :/

If we get more reports like that, we might implement a logic to
prevent infinite loops.

It is not clear to me what exactly happened to this driver, since
testing napi_complete_done() was not mandatory.
