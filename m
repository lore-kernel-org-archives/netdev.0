From: Brad Chapman <jabiru_croc@yahoo.com>
Subject: Re: kern mod versioning
Date: Wed, 20 Nov 2002 14:56:18 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021120225618.28279.qmail@web40003.mail.yahoo.com>
References: <001701c290a9$cd049ea0$7544903f@a>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Cunningham <billcu@citynet.net>
In-Reply-To: <001701c290a9$cd049ea0$7544903f@a>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- Bill Cunningham <billcu@citynet.net> wrote:
> I've been trying to learn how to build modules, Modules I guess being
> drivers and I can't get around the kern versioning. I know I can compile it
> out of the kernel but isn't there a simpler way around it, like disabling it
> in the module source? BTW I use kern 2.2
> 

CONFIG_MODVERSIONS=n

Then run make mrproper after saving your .config and proceed from there.

Brad

__________________________________________________
Do you Yahoo!?
Yahoo! Web Hosting - Let the expert host your site
http://webhosting.yahoo.com
