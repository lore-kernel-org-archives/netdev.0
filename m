From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Allow multiple dummy devices again
Date: Thu, 27 Nov 2003 17:13:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127171313.04f89baa.davem@redhat.com>
References: <20031128004445.GA2870@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20031128004445.GA2870@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Nov 2003 01:44:45 +0100
Andi Kleen <ak@muc.de> wrote:

> In 2.6 the old trick of copying the dummy module to get multiple dummy
> devices doesn't work anymore because the "dummy" device name is embedded
> in the module. 
> 
> This patch adds a new module option that allows to specify how many
> dummy devices you want.

Jeff, FWIW I'm fine with this.

Even though we generally frown upon module options for networking
devices, I think it's wholly appropriate for this case.
