From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Sharing /proc file
Date: Fri, 20 Feb 2004 14:29:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220142914.2f405104@dell_ss3.pdx.osdl.net>
References: <20040220221506.9945.qmail@web40712.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Niranjan <niranjan_cs2905@yahoo.com>
In-Reply-To: <20040220221506.9945.qmail@web40712.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2004 14:15:06 -0800 (PST)
Niranjan <niranjan_cs2905@yahoo.com> wrote:

> Hi,
> Is it possible to share a /proc file between two
> kernel modules?
> Also, what is the best way to share a structure
> between two kernel modules ?
> 
> Regards,
> -Niranjan

If the two modules are so interrelated, why have them separate?
You can use EXPORT_SYMBOL() to share globals between modules.
I can't see a good reason to ever share a single /proc file.
The module that defines the symbol must be the one that manages
the /proc interaction with that structure.
