From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 13:35:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030203550.GB6256@gate.ebshome.net>
References: <1099030958.4944.148.camel@uganda> <1099053738.1024.104.camel@jzny.localdomain> <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 06:06:52PM +0400, Evgeniy Polyakov wrote:
> If we have a hardware accelerator chip, than we _already_ have improvements 
> with even the worst async crypto layer, since software and hardware 
> will work in parrallel.

This is not true. 

For example, if chip request setup and PCI transfer takes more than 
just using sw implementation. This is reality for AES and short 
packets.

--
Eugene
