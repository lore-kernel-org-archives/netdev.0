From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 17:55:12 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.NEB.4.33.0407061751380.10143-100000@dexter.psc.edu>
References: <20040706133559.70b6380d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040706133559.70b6380d.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Another bit to addr to the firewall / window scale mess:  I remember from
a while ago that the Cisco PIX firewalls would not allow a window scale of
greater than 8.  I don't know if they've fixed this or not.  It seems
like some sort of arbitrary limit.

This is obviously not the problem people are seeing now, but could be a
problem in the future.

  -John

