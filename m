From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 14/15] module_param: make bool parameters really bool
 (net & drivers/net)
Date: Thu, 15 Dec 2011 16:33:40 -0800
Message-ID: <1323995620.18603.4.camel@joe2Laptop>
References: <877h1ysenl.fsf@rustcorp.com.au>
	 <1323920752.29500.11.camel@joe2Laptop> <87k45xqvfs.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k45xqvfs.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-12-16 at 09:44 +1030, Rusty Russell wrote:
> I could, but as I was touching 457 files, so I was aiming for minimal
> changes.

> Dave, did you want a true/false cleanup too?

Hi Rusty.

Did you perform these transforms via spatch?
If not, here's a trivial spatch script for those files.

$ cat bool.cocci
@@
bool b
@@
-b = 0
+b = false
@@
bool b
@@
-b = 1
+b = true
