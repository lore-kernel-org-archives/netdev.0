From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipchains masquerade must select maddr correctly
Date: Tue, 2 Dec 2003 16:58:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202165850.3f8c16c4.davem@redhat.com>
References: <20031202162208.04629dab.davem@redhat.com>
	<Pine.LNX.4.44.0312030231240.1237-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, laforge@gnumonks.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312030231240.1237-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Dec 2003 02:50:56 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> TOS matching and hash key should be
> a sysctl/compile time option?

It already is, CONFIG_IP_ROUTE_TOS.  But the issue is that
all dist vendors enable that.

Also note that what you propose could potentially break
some setups.
