From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 20:45:51 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029204551.06caaf4b@zanzibar.2ka.mipt.ru>
References: <1099062483.1023.21.camel@jzny.localdomain>
	<Xine.LNX.4.44.0410291213380.21689-100000@thoron.boston.redhat.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, <netdev@oss.sgi.com>, <cryptoapi@lists.logix.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0410291213380.21689-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 12:16:35 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> On 29 Oct 2004, jamal wrote:
> 
> > On Fri, 2004-10-29 at 10:06, Evgeniy Polyakov wrote:
> > 
> > 
> > > If we have a hardware accelerator chip, than we _already_ have improvements 
> > > with even the worst async crypto layer, since software and hardware 
> > > will work in parrallel.
> > 
> > Thats what i am hoping - and theory points to it. Numbers, numbers
> > please ;->
> 
> There's an OpenBSD paper which demonstrates the usefulness of crypto
> hardware for reducing cpu contention.  I can't get to their web site now,
> but it's there somewhere under a security link.

Asynchronous crypto layer was written under impression of those paper.
OpenBSD layer is very good, but it has some nitpics some of which are really
not good, but I hope all of them are resolved in my driver.

You can find paper for example there: http://www.madchat.org/crypto/ocf.pdf

> 
> - James
> -- 
> James Morris
> <jmorris@redhat.com>
> 
> 


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
