From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] (10/11) netrom - convert /proc interface to seq_file
Date: Fri, 15 Aug 2003 18:12:17 -0300
Sender: linux-hams-owner@vger.kernel.org
Message-ID: <20030815211217.GL1564@conectiva.com.br>
References: <20030813154635.376df59b.shemminger@osdl.org> <20030814172539.GD1785@conectiva.com.br> <20030814113025.2b40be14.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
	Jeroen Vreeken <pe1rxq@amsat.org>, linux-hams@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-hams-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030814113025.2b40be14.shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

Em Thu, Aug 14, 2003 at 11:30:25AM -0700, Stephen Hemminger escreveu:
> On Thu, 14 Aug 2003 14:25:39 -0300
> Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> > <nitpick> why not just one seq_printf call? </nitpick>
> 
> ax2asc() returns a pointer to static buffer.

argh :-\ Even if only for correctness shouldn't it receive a buffer, like
snprintf, etc?

- Arnaldo
