From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:13:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE40F1.4030107@us.ibm.com>
References: <3EEE28DE.6040808@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, stekloff@us.ibm.com,
   girouard@us.ibm.com, lkessler@us.ibm.com, kenistonj@us.ibm.com,
   Jeff Garzik <jgarzik@pobox.com>, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Janice M Girouard <janiceg@us.ibm.com>
In-Reply-To: <3EEE28DE.6040808@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Janice M Girouard wrote:

> Below is a patch that demonstrates standard messages for ethernet device 
> drivers.  I would like your feedback on the concept of standard network 
> messages, and any suggestions for messages to include. 

Very useful!  I'd like to see a short note on this in Documentation/
networking..Or perhaps if there is already a RAS best practices
kind of doc or something, add to that? (sorry, havent checked)
But it would be handy for people who wanted to contribute
patches for other drivers.

Essentially, things like some guidelines on classifying some
of those messages, when creating new messages. eg when is
something a state change and when is it a performance event?
I notice some slight ambiguity in your defs..(sorry, very
minor nitpick :)).

I'd certainly like to see messages from the driver when the
card enters/leaves promiscuous mode, as an example of things
we'd like to add...

thanks,
Nivedita


> The intent of the standard message change is to:
> 1) Ensure key events are communicated to user space in a predictable 
> way, enabling automated diagnostic systems or error log analysis,
> 2) Reduce the number of puzzling messages that are logged -- in this 
> case, by replacing them with standard messages, and/or
> 3) Identify the device (or driver name) that is responsible for the error.
