From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vxlan: Wrong type passed to %pIS
Date: Fri, 06 Feb 2015 19:35:38 -0800
Message-ID: <1423280138.2933.3.camel@perches.com>
References: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-02-07 at 03:17 +0100, Rasmus Villemoes wrote:
> src_ip is a pointer to a union vxlan_addr, one member of which is a
> struct sockaddr. Passing a pointer to src_ip is wrong; one should pass
> the value of src_ip itself. Since %pIS formally expects something of
> type struct sockaddr*, let's pass a pointer to the appropriate union
> member, though this of course doesn't change the generated code.

Hello Rasmus

Are you finding these mismatches by hand or
are you using some tool?
