From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu,  5 Sep 2002 15:39:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1031265571.3d77dd23caec4@imap.linux.ibm.com>
References: <200209052211.g85MBFdm099387@tempest.prismnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: jamal <hadi@cyberus.ca>, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Troy Wilson <tcw@tempest.prismnet.com>
In-Reply-To: <200209052211.g85MBFdm099387@tempest.prismnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Troy Wilson <tcw@tempest.prismnet.com>:

> > Do you have any stats from the hardware that could show
> > retransmits etc;
> 
>   I'll gather netstat -s after runs with and without TSO enabled.
> Anything else you'd like to see?

Troy, this is pointing out the obvious, but make sure
you have the before stats as well :)...

> > have you tested this with zero copy as well (sendfile)
> 
>   Yes.  My webserver is Apache 2.0.36, which uses sendfile for
> anything
> over 8k in size.  But, iirc, Apache sends the http headers using
> writev.

SpecWeb99 doesnt execute the path that might benefit the 
most from this patch - sendmsg() of large files - large writes
going down..

thanks,
Nivedita
