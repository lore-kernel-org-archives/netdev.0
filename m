From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Thu, 10 Mar 2005 20:42:46 -0800
Message-ID: <20050311044246.GT3120@waste.org>
References: <2.454130102@selenic.com> <422A4A38.4040303@trash.net> <20050306002015.GD3120@waste.org> <422A564D.4080809@trash.net> <20050310230117.GP3120@waste.org> <42311FF9.5010007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42311FF9.5010007@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2005 at 05:35:05AM +0100, Patrick McHardy wrote:
> Matt Mackall wrote:
> >Ok, on closer inspection, the current logic is: the NIC reports
> >carrier detect nearly instaneously and thus its carrier detect
> >reporting is considered unreliable. Rather than immediately sending
> >packets, we wait for some interval for it to really be up so that the
> >backlog of console messages doesn't get pumped into the bit bucket.
> >
> >So I'm going to change it from "flaky" to "untrustworthy" and add a
> >comment.
> 
> Why don't you trust an instaneously available carrier? Any
> reason to assume there will be false positives?

Because I had reports of people losing all their boot messages until
this logic was added (about a year ago now?). I don't remember which
NICs were implicated, but some apparently report carrier is always
available.

-- 
Mathematics is the supreme nostalgia of our time.
