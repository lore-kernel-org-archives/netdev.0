From: Chris Wedgwood <cw@f00f.org>
Subject: CodingStyle: while ((a=b))
Date: Sat, 26 Jun 2004 16:42:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626234221.GB12761@taniwha.stupidest.org>
References: <200406262245.i5QMjn65009470@ginger.cmf.nrl.navy.mil> <20040626225230.GA12698@taniwha.stupidest.org> <20040626162641.00786ed6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas@cmf.nrl.navy.mil, shemminger@osdl.org, netdev@oss.sgi.com,
        Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040626162641.00786ed6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 26, 2004 at 04:26:41PM -0700, David S. Miller wrote:

> I think warning for the ((a=b)) case is annoying but not annoying
> enough to fight against it :)

Whatever the case, even if I don't like it I would rather see it
consistent.

Maybe Linus can comment as to whether or not we officially
(Documentation/CodingStyle update) want to change things like:

    while ((a=b)) to while ((a=b) != 0)

and similar throughout the code?


  --cw
