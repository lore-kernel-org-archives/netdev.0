From: "David S. Miller" <davem@redhat.com>
Subject: Re: High interrupt rate even when using NAPI
Date: Wed, 5 Nov 2003 10:07:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105100750.63974931.davem@redhat.com>
References: <3FA93B82.5070508@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
In-Reply-To: <3FA93B82.5070508@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 05 Nov 2003 12:03:46 -0600
Steve Modica <modica@sgi.com> wrote:

> I just noticed some strange behavior with the tg3 driver.

The tg3 driver needs to poke the chip a hundred times per
second in order to work around a hardware bug, eack poke
causes an interrupt.  This is needed regardless of whether
the chip is processing packets or not.
