From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Tue, 21 Dec 2004 01:22:30 +0100
Message-ID: <20041221002230.GZ17998@postel.suug.ch>
References: <20041219203050.GK17998@postel.suug.ch> <41C68CEF.3030803@trash.net> <1103552215.1048.333.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103552215.1048.333.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, drop this one. I will move indev into the abstraction layer
i'm going to introduce .11 which will fix the current issues, remove
the ifdefs and will make removal/replacement much simpler once
we have metadata match.
