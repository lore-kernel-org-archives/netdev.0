From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 01:43:56 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0410310137310.28135-100000@thoron.boston.redhat.com>
References: <20041030092036.4f954d89@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <cryptoapi@lists.logix.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20041030092036.4f954d89@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004, Evgeniy Polyakov wrote:

> > Also, please consider EXPORT_SYMBOL_GPL instead of EXPORT_SYMBOL.
> 
> I'm not insisting, but why?

The existing crypto API uses EXPORT_SYMBOL_GPL, and I would hope that
extensions to it do the same.  This area is contentious in general, but
ultimately, I think we should document that these APIs are not intended to
be used by proprietary modules to do things like plug into the kernel and
extend it in proprietary ways.


- James
-- 
James Morris
<jmorris@redhat.com>
