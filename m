From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make z8530.c build on 2.6
Date: Wed, 13 Aug 2003 18:28:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3ABB7A.5080204@pobox.com>
References: <20030813132501.01eb1ecf.shemminger@osdl.org> <1060813424.9130.61.camel@dhcp23.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   Nenad Corbic <ncorbic@sangoma.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1060813424.9130.61.camel@dhcp23.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> and doesn't need zeroed pages, I've just got no idea what 2.6 decided
> to call the give me a free page function, fix that and it'll work fine.


Look at 2.4 ;-)

include/linux/mm.h:#define get_free_page get_zeroed_page
