From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Thu, 18 Sep 2003 19:48:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918194802.6726d53c.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<20030916140918.GF810@obroa-skai.de.gnumonks.org>
	<20030916181603.366b7c06.davem@redhat.com>
	<200309172317.38348.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, hno@marasystems.com, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309172317.38348.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Sep 2003 23:17:38 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> Let me try to convince you one more time :)

Sure, but let me give you a suggestion, OK?

Don't use an alignment attribute, just put the member of
the struct at the very beginning and use "unsigned int"
at a time op+comparisons.

How about that?
