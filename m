From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATRCH] janitor: hermes: delete verify_area call
Date: Mon, 29 Sep 2003 22:15:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929221546.7871ddf7.davem@redhat.com>
References: <20030925215902.57f53822.rddunlap@osdl.org>
	<20030929052925.GA5037@zax>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Gibson <hermes@gibson.dropbear.id.au>
In-Reply-To: <20030929052925.GA5037@zax>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003 15:29:25 +1000
David Gibson <hermes@gibson.dropbear.id.au> wrote:

> Sorry, can you clarify why this verify_area() is not needed?

copy_{to,from}_user() and friends do the verify_area().
