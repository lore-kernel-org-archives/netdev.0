From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdevice->generate_eui64
Date: Sun, 1 Feb 2004 15:24:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040201152435.34f4231e.davem@redhat.com>
References: <20040130170316.789e8939.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: schwidefsky@de.ibm.com, zaitcev@redhat.com, utz.bacher@de.ibm.com,
        pavlic@de.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20040130170316.789e8939.zaitcev@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jan 2004 17:03:16 -0800
Pete Zaitcev <zaitcev@redhat.com> wrote:

> Does anyone know where I can find a patch to add dev->generate_eui64?
> The qeth in 2.6 tree requires it to be built (with IPv6). I am talking
> about a descendant of this patch:
>  http://www.ussg.iu.edu/hypermail/linux/net/0303.0/0037.html

I don't want to see this btw, as I mentioned ipv6 specific things do not
belong in the generic device struct.  There surely are better ways and I'm
totally open to suggestions.
