From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [he] unconditionalize extra pci reads to flush
 posted writes
Date: Wed, 11 Feb 2004 22:04:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211220424.7820b0bc.davem@redhat.com>
References: <200402111429.i1BETlRr005845@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200402111429.i1BETlRr005845@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 09:29:48 -0500
chas williams (contractor) <chas@cmf.nrl.navy.mil> wrote:

> since its difficult to tell which pci bus is using
> posted writes, remove the ifdef's for the sgi sn2
> (and remove the extra flushes that would be flushed
> by other reads just slightly later).  the extra reads
> shouldnt impact performance.
> 
> please apply to 2.6 and 2.4

The readbacks should apply to many platforms anyways.
Applied, thanks Chas.
