From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][SCTP] Fix bug in sctp_init() error handling code.
Date: Sun, 24 Apr 2005 20:29:26 -0700
Message-ID: <20050424202926.2d04e546.davem@davemloft.net>
References: <Pine.LNX.4.61.0504221217120.5192@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0504221217120.5192@dyn9047018105.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 12:28:39 -0700 (PDT)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Please apply to 2.6.

I can't, something is mangled in your patches.  It too me a while
to figure out what was wrong but it's in the context lines not
modified by your patch.

> @@ -1159,8 +1159,6 @@
>   	status = 0;
>   out:
>   	return status;
> -err_add_protocol:
> -	proto_unregister(&sctp_prot);

Two leading spaces, then a tab, thus the patch doesn't apply.
That's a signature of a "*.rej" file btw.

Please resubmit the whole batch of SCTP patches you have once
you've corrected this problem.
