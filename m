From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net,
	bridge: print log message after state changed
Date: Thu, 17 Nov 2011 14:40:23 -0800
Message-ID: <20111117144023.06c8502e@nehalam.linuxnetplumber.net>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
	<20111114.003702.1097206603722725705.davem@davemloft.net>
	<1321254211.4072.29.camel@pc005091.de.keymile.net>
	<20111114.020749.1176229013272872343.davem@davemloft.net>
	<20111117192353.GD2051622@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang.Fritz@keymile.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, holger.brunck@keymile.com,
	shemminger@linux-foundation.org, David Miller <davem@davemloft.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20111117192353.GD2051622@jupiter.n2.diac24.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Nov 2011 20:23:53 +0100
David Lamparter <equinox@diac24.net> wrote:

> There seems to be a misunderstanding here. The patch effectively does:
> -       br_log_state(p);
>         p->state = BR_STATE_DISABLED;
> +       br_log_state(p);
> 
> and the issue it is trying to fix is not the timing but rather the code
> printing the wrong (old, now-left) state.
> 
> I do agree that the log message should be printed before anything
> happens, so, Holger, can you brew a patch that does that?

Other than being horribly strict, why bother? I hope you aren't building
some application that depends on the ordering of the log message.
The state change doesn't get undone, why does the order of the message
matter at all?
