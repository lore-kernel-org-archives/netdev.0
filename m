From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tulip: de2104x, fix init. sections
Date: Wed, 02 Mar 2005 01:09:54 -0500
Message-ID: <422558B2.6020105@pobox.com>
References: <20050301214438.4653810e.randy.dunlap@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, torvalds <torvalds@osdl.org>, akpm <akpm@osdl.org>
To: "Randy.Dunlap" <randy.dunlap@verizon.net>
In-Reply-To: <20050301214438.4653810e.randy.dunlap@verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> tulip/de2104x: some __devinit functions were calling __init
>   functions, made the latter __devinit also;

Should go the other way:  all the stuff in de2104x should be __init, not 
__devinit.

Nobody ever hotplugs a de2104x.

	Jeff
