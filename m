From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Mon, 17 Jun 2002 14:33:19 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <aell3m$vd$2@main.gmane.org>
References: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: critson@perlfu.co.uk
In-Reply-To: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk>
List-Id: netdev.vger.kernel.org


This is a known bug introduced by the struct sock splitup into
external per-protocol pieces done by Arnaldo de Melo.  He is working
on the proper fix, your proposed change will just paper over the real
bug.
