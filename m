From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.10-rc2] 3c59x: reload EEPROM values at rmmod for
 needy cards
Date: Wed, 17 Nov 2004 13:44:25 -0800
Message-ID: <20041117134425.62034944.akpm@osdl.org>
References: <20041117160122.A4824@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20041117160122.A4824@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"John W. Linville" <linville@tuxdriver.com> wrote:
>
> 3c905 cards need an additional bit unmasked in the reset at rmmod or
> else they don't get reinitialized properly when the driver is reloaded.

This has been in -mm kernels since you first sent it out.  I'm intending to
hold off until post-2.6.10 so we get a full kernel cycle for any problems
to get shaken out.
