From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] switch sdla to initcalls
Date: Wed, 21 May 2003 12:31:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521123123.40924dce.ak@suse.de>
References: <20030521081938.GD22869@wotan.suse.de>
	<20030521102512.A30373@lst.de>
	<20030521082630.GF22869@wotan.suse.de>
	<20030521.013453.118618445.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030521.013453.118618445.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 May 2003 01:34:53 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

> I have to admit that I must feign ignorance here.  And that someone
> who really understands the EISA/ISA probe ordering requirements
> should document them as best as possible in Space.c

I doubt anybody understands it. It is just lots of hard earned ad-hoc 
experience distilled in these files.

It's basically untestable/unknown because you'll likely have a hard time
to find such a card anymore. And even if you had you would need the other
ISA cards that could possible conflicts to test all combinations - impossible
task. For such unsolvable problems it is best to leave it untouched because it
cannot be tested. Either that or remove the driver completely.

-Andi
