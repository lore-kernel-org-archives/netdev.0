From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] drivers/net: dlink: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 13:44:45 +0300
Message-ID: <CAOJe8K2nM246QC44+Wy4kC9zBiwhL2-RR=varLkqkG=Yuo4xMg@mail.gmail.com>
References: <20171027055459.GA105727@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027055459.GA105727@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/17, Kees Cook <keescook@chromium.org> wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
>
> Cc: Denis Kirjanov <kda@linux-powerpc.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Denis Kirjanov <kda@linux-powerpc.org>
