From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Tue, 9 Nov 2004 16:18:16 -0800
Message-ID: <20041109161816.425ad7d6.davem@davemloft.net>
References: <418B4C7C.8000402@crocom.com.pl>
	<418EA032.7050507@trash.net>
	<418ECE85.9090203@trash.net>
	<20041108135431.GE31969@postel.suug.ch>
	<418F9AD0.1040701@trash.net>
	<20041108183300.GF31969@postel.suug.ch>
	<418FCD0A.4040202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, spam@crocom.com.pl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418FCD0A.4040202@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 08 Nov 2004 20:46:18 +0100
Patrick McHardy <kaber@trash.net> wrote:

> New patch attached.

How do these child qdiscs get destroyed at all if you just
remove them from the lists they are on?  How will the rest
of destroy processing find them and clean them up?
