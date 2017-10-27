From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] net: tipc: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 06:58:00 +0200
Message-ID: <CAGXu5jKzCDeW2UaEB4EK2uy4wjC6TidFQtSTj0-F2jLYgZXq0A@mail.gmail.com>
References: <20171024084637.GA23944@beast> <AM4PR07MB1714904E90C690AD11257B189A470@AM4PR07MB1714.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Ying Xue <ying.xue@windriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR07MB1714904E90C690AD11257B189A470@AM4PR07MB1714.eurprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 11:44 AM, Jon Maloy <jon.maloy@ericsson.com> wrote:
> NAK. It doesn't sound like a good idea to send this to net. Especially since one of these timers has already been refactored in net-next.

Hi! I'm not sure what you mean about the one timer issue. I don't see
any use of timer_setup() in net/tipc (and no recent conversions to the
older setup_timer() API). What's the preferred path for landing this
API conversion in net/tipc/?

And, just to note, these changes are almost entirely mechanical. The
only "special" case is in tipc_sk_timeout() where the argument needs
to be slightly adjusted to fetch the tsk from the sk again.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
