From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bug in ARP override timer near jiffies wrap
Date: Fri, 7 May 2004 14:55:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040507145501.24fdd83a.davem@redhat.com>
References: <20040507144000.7a57d76a.davem@redhat.com>
	<OFCBE52D62.180AE438-ON88256E8D.0077E81B-88256E8D.00780545@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFCBE52D62.180AE438-ON88256E8D.0077E81B-88256E8D.00780545@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 May 2004 14:51:13 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> David S. Miller wrote on 05/07/2004 02:40:00 PM:
> 
> > David, do you realize that the existing formula is not only
> > correct, but also covers a greater time space than the
> > time_*() mechanisms do?
> 
> ARG! you're right, of course-- I noticed only that they are
> different and didn't think about it actually be right! :-)

But note that the main point is also that your change is
still correct.

The only reason I know about the time space issue with these
tests is that Alexey mentioned it to me when I was converting
most of the TCP code over to use the time_*() macros.

It is a policy decision whether it is more valuable to be
more consistent or support the larger time space in tests
here and there.

I think it is more important to be consistent, so I'm going
to apply your patch.  And for ARP the larger time space would
never matter anyways :-)
