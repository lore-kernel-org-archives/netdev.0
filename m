From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: acenic: Unhandled event 0x24
Date: 30 Jun 2004 01:41:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <yq0eknx4n82.fsf@wildopensource.com>
References: <20040629154751.20f4772a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040629154751.20f4772a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:

Stephen> When the acenic gigabit ether card is under lots of receive
Stephen> pressure, it generates many (not excessive) console output
Stephen> about Unhandled event 0x24

Stephen> I presume this is because the receive ring is getting over
Stephen> run and packet was dropped.

Weird!

This is another one thats not listed in the programming manual. I have
never seen it spew out event 0x24 messages, no idea what they are
for. If you want to add a patch to rate-limit it I would have no
objections.

Cheers,
Jes
