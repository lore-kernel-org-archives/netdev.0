From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (3/3) Space.c -- fix boot param string setup
Date: Tue, 23 Sep 2003 12:00:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923120005.2f47f72a.davem@redhat.com>
References: <20030923101448.71ea19d5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030923101448.71ea19d5.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 10:14:48 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> My conversion of probing to dynamic allocation, lost the ability to
> set boot parameters properly.  Need to assign network device name before
> lookup in order for this to work.

Applied.

Something similar is needed for all the ISA etc. ethernet drivers
too.  In particular 3c509.c is busted in this area currently.
