From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 15:50:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706155013.32af8e13.davem@redhat.com>
References: <20040706133559.70b6380d.davem@redhat.com>
	<Pine.NEB.4.33.0407061751380.10143-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0407061751380.10143-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 17:55:12 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> Another bit to addr to the firewall / window scale mess:  I remember from
> a while ago that the Cisco PIX firewalls would not allow a window scale of
> greater than 8.  I don't know if they've fixed this or not.  It seems
> like some sort of arbitrary limit.

In what manner did it deal with > 8 window scales?  By rewriting the option
or deleting the option entirely from the SYN or SYN+ACK packets?
