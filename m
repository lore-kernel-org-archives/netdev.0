From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] broadcast address on subnet
Date: Mon, 5 Jul 2004 15:35:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705153538.51efe4a5.davem@redhat.com>
References: <20040630125858.K68876-100000@xs1.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jaap Keuter <jaap.keuter@xs4all.nl>
In-Reply-To: <20040630125858.K68876-100000@xs1.xs4all.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jun 2004 13:02:16 +0200 (CEST)
Jaap Keuter <jaap.keuter@xs4all.nl> wrote:

> Digging a bit deeper revealed that it actually is an issue with
> SIOIFNETMASK. Once you bring up an interface with SIOIFADDR, a classfull
> netmask and broadcast address is set (if applicable for the type of
> interface), in order to get a properly configured interface. But if you
> subnet the network using SIOIFNETMASK no proper broadcast address is
> set. So you always have to calculate it yourself, obviously leading to
> configuration errors.

Indeed that's odd behavior.  I like this patch and will apply it
to my trees.

Thanks.
