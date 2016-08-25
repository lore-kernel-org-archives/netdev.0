From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: ax88179_178a: Add support for writing the EEPROM
Date: Thu, 25 Aug 2016 11:16:36 +0200
Message-ID: <1472116596.2877.23.camel@suse.com>
References: <20160824135231.21782-1-alban.bedel@avionic-design.de>
         <1472049039.11480.10.camel@suse.com> <20160824164058.6ec64a8e@avionic-0020>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Freddy Xin <freddy@asix.com.tw>, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Alban Bedel <alban.bedel@avionic-design.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160824164058.6ec64a8e@avionic-0020>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-24 at 16:40 +0200, Alban Bedel wrote:
> On Wed, 24 Aug 2016 16:30:39 +0200
> Oliver Neukum <oneukum@suse.com> wrote:
> 
> > On Wed, 2016-08-24 at 15:52 +0200, Alban Bedel wrote:

> > > +       if (block != data)
> > > +               kfree(block);  
> > 
> > And if block == dta, what frees the memory?
> 
> In this case this function didn't allocate any memory, so there is
> nothing to free.

Hi,

I see. kfree() has a check for NULL, so you could drop the
test, but it doesn't matter much either way.

	Regards
		Oliver
