From: "David S. Miller" <davem@redhat.com>
Subject: Re: forcing bottom half to a specific processor on numa
Date: Fri, 29 Aug 2003 16:44:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829164421.549c20d1.davem@redhat.com>
References: <200308291549.h7TFngl5014364@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200308291549.h7TFngl5014364@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 11:49:43 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> is there a reason i shouldnt do this?  is there a better way?

Just bind the interrupts of your card to a processor local
to the numa node in question using the IRQ affinity stuff.

Then all softints you schedule will run on that processor
too, when you schedule a softint or a tasklet it runs on
the cpu where you perform that schedule.
