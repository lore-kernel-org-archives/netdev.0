From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 15:42:17 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0410301541270.26912-100000@thoron.boston.redhat.com>
References: <Pine.LNX.4.61.0410301805360.14888@maxipes.logix.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, <netdev@oss.sgi.com>,
        <cryptoapi@lists.logix.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <Pine.LNX.4.61.0410301805360.14888@maxipes.logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004, Michal Ludvig wrote:

> - I would choose a different directory strucrure. Instead of 
> drivers/acrypto and drivers/connector I'd put the device-independent 
> parrts info e.g. crypto/acrypto and the drivers (e.g. Fcrypt or PadLock) 

Agreed, do we need a separate acrypto subdirectory?  Why not just put the 
async code directly under crypto.


- James
-- 
James Morris
<jmorris@redhat.com>
