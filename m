From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFR: new SiS gige driver
Date: Fri, 8 Aug 2003 23:39:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808233940.6ad767f5.davem@redhat.com>
References: <20030808173932.GA4077@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030808173932.GA4077@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Aug 2003 13:39:33 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> This driver is actually a lot more clean than many that crop up.  So far
> most of my nits are minor:

egrep virt_to_bus sis190.c

:-(

I think this is more important to fix than any of the other things
which have been listed.  I really believe we're at the point where
putting PCI device drivers into the tree still using virt_to_bus() and
friends should simply not be allowed...
