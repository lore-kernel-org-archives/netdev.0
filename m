From: shemminger@osdl.org
Subject: Re: [PATCH] (15/23) sk98: rearrange initialization
Date: Fri, 12 Nov 2004 20:43:47 -0800 (PST)
Message-ID: <60183.63.170.215.71.1100321027.squirrel@www.osdl.org>
References: <4192C60A.1050205@designassembly.de>
    <20041111154225.5cf85567@zqx3.pdx.osdl.net>
    <20041111160113.15a356cd@zqx3.pdx.osdl.net>
    <20041112163041.GC7066@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
        "Jeff Garzik" <jgarzik@pobox.com>,
        "Michael Heyse" <mhk@designassembly.de>,
        "Mirko Lindner" <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041112163041.GC7066@infradead.org>
To: "Christoph Hellwig" <hch@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Thu, Nov 11, 2004 at 04:01:13PM -0800, Stephen Hemminger wrote:
>> The code in the latest SysKonnect driver is arranged differently,
>> this aligns the two versions to allow for easier comparisons.
>> Also:
>> 	Don't enable the pci device twice.
>> 	Add common SkGeDevInit for common code used to setup both ports
>
> please don't reorder the functions.  I placed them in natural order when
> converting to new pci probing for a good reason.

I really don't care which way it goes, just trying to make SysKonnect's
life easeier.  When all the comments are in, I will redo the patches
without the reordering
