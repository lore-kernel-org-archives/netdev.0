From: Andi Kleen <ak@suse.de>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 12 Nov 2003 00:53:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111235330.GA25553@wotan.suse.de>
References: <3F8802E6.5030601@sgi.com> <20031011131921.GC21763@wotan.suse.de> <20031011105054.0e16a607.davem@redhat.com> <3F8C290A.3010508@sgi.com> <20031014095323.71c8b9fe.davem@redhat.com> <3FB03A56.7000709@sgi.com> <20031110182911.2c5a121b.davem@redhat.com> <3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com> <3FB15725.4050705@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, ak@suse.de, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com, David Mosberger <davidm@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Partridge <johnip@sgi.com>
Content-Disposition: inline
In-Reply-To: <3FB15725.4050705@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +config CONFIG_UNALIGNED_EXPENSIVE
> +       bool "Use kernel aligned buffers"

Drop the "bool" line. Then it will be invisible, which is the right thing here.
     
> +       depends on IA64
> +       default y
> +

-Andi
