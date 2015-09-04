From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Remove conntrack Kconfig option.
Date: Fri, 4 Sep 2015 16:23:12 -0700
Message-ID: <CALnjE+p+UB5o-TShVbGVHMm2pO5PNwLCdZEQhiXGa_f8h5Pbeg@mail.gmail.com>
References: <1441397260-61272-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1441397260-61272-1-git-send-email-joestringer@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 4, 2015 at 1:07 PM, Joe Stringer <joestringer@nicira.com> wrote:
> There's no particular desire to have conntrack action support in Open
> vSwitch as an independently configurable bit, rather just to ensure
> there is not a hard dependency. This exposed option doesn't accurately
> reflect the conntrack dependency when enabled, so simplify this by
> removing the option. Compile the support if NF_CONNTRACK is enabled.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
