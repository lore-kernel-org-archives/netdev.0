From: "David S. Miller" <davem@redhat.com>
Subject: Re: =?ISO-8859-1?Q?R=E9f.?= : Fw: [BUG/PATCH]
 CONFIG_NET_HW_FLOWCONTROL and SMP
Date: Tue, 30 Sep 2003 00:08:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930000827.586fdac1.davem@redhat.com>
References: <C1256DB1.00272341.00@arkoon-mail.arkoon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dfages@arkoon.net
In-Reply-To: <C1256DB1.00272341.00@arkoon-mail.arkoon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003 09:07:28 +0200
dfages@arkoon.net wrote:

> Yes, I know that but, for the moment, I've to keep my 2.4.19 kernel
> (so without NAPI).  I've also ported the e1000 driver to
> HW_FLOWCONTROL. Some people may be happy to use it...

I agree to adding the bug fix, it's a bug fix and for code we can't
remove from the 2.4.x series at this point.

I don't agree to adding usage of this deprecated feature to any
drivers shipped in the kernel.  If you're going to invest time into
making this kind of improvement, invest it in a NAPI port.

So I'll add your bug fix, thanks.
