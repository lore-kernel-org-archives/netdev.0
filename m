From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tg3 h/w flow control autoneg
Date: Tue, 25 May 2004 13:01:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525130153.49af3d78.davem@redhat.com>
References: <20040524072657.GC27177@sgi.com>
	<20040524004045.58b3eb44.davem@redhat.com>
	<20040524080431.GD27177@sgi.com>
	<20040524100634.1349295d.davem@redhat.com>
	<20040525010434.GA31134@sgi.com>
	<20040525105101.2da85469.davem@redhat.com>
	<Pine.SGI.4.56.0405251158550.9934718@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.SGI.4.56.0405251158550.9934718@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 May 2004 12:20:05 -0700
Arthur Kepner <akepner@sgi.com> wrote:

> The problem turned out to be that h/w flow control wasn't
> being used, even after that should have been autonegotiated.
> The attached patch (against 2.6.6) fixes that.

What an embarassing bug.  Patch applied, good spotting Arthur.
