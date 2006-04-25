From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: is it a backwards compatability catch-22?
Date: Tue, 25 Apr 2006 09:09:31 -0700
Message-ID: <4807377b0604250909m34f6030ar19735b3343884399@mail.gmail.com>
References: <444D6396.4010004@hp.com>
	 <20060424165407.202a86f4@dxpl.pdx.osdl.net> <444D6F78.9080309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"Linux Network Development list" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xproxy.gmail.com ([66.249.82.205]:7123 "EHLO xproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751555AbWDYQJr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 12:09:47 -0400
Received: by xproxy.gmail.com with SMTP id t10so878999wxc
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 09:09:46 -0700 (PDT)
To: "Rick Jones" <rick.jones2@hp.com>
In-Reply-To: <444D6F78.9080309@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/06, Rick Jones <rick.jones2@hp.com> wrote:
>
> > The udev stuff runs after the device has already chosen it's default name.
> > It has to, it's part of the hotplug infrastructure, and we don't want
> > to depend on usermode to define the name.  Just choose some other
> > convention "eth_0"  or something like that.
>
> Is that because adding another NIC at a later time might cause it to
> grab ethN out from under what I'm trying to do with udev?

>From what I read its likely to be because there may already be a
device named "eth1" due to default naming when you are trying to
rename a device (say eth0) to eth1.

this is all because Debian now has async init, right?

BTW, since the letters in udev are all hex, it shouldn't matter
whether they are upper or lower case, IMO

Jesse
