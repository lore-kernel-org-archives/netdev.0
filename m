From: "Sebastian Piecha" <spi@gmxpro.de>
Subject: Re: oops in skbuff.c
Date: Thu, 16 Oct 2003 23:11:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8F25BA.16275.5B4D703@localhost>
References: <3F8F152F.4147.5743B2C@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>, LK-net <linux-net@vger.kernel.org>,
        <netdev@oss.sgi.com>
In-reply-to: <Xine.LNX.4.44.0310161635590.6371-100000@thoron.boston.redhat.com>
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 16 Oct 2003 at 16:37, James Morris wrote:

> On Thu, 16 Oct 2003, Sebastian Piecha wrote:
> 
> > On 16 Oct 2003 at 15:15, James Morris wrote:
> > > On Thu, 16 Oct 2003, Sebastian Piecha wrote:
> > > 
> > > Does the above cause a panic for the 2.6-test kernels?
> > > Do you have netfilter enabled, and if so, any iptables modules loaded?
> > > 
> > No. Only in 2.4-kernels. No netfilter. No iptables. Just samba 
> > sharing some reiserfs directories on a Promise attached ide harddisk.
> 
> Are you able to test with a different NIC to the onboard 3C905B?
> 
> 

Unfortunately I only have 3com NICs. Do you think it's the adapter? 
But why it's working in kernel 2.6? There are different changes in 
skbuff.c between kernel 2.4.22-ac4 and 2.6.0-test7. Is there any 
slight chance to port it back to 2.4.x?

Mit freundlichen Gruessen/Best regards,
Sebastian Piecha

EMail: spi@gmxpro.de
