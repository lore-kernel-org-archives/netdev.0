From: Liu Jiusheng <liujiusheng@gmail.com>
Subject: Re: Getting IP Address for netdev
Date: Fri, 25 Sep 2009 21:43:52 +0800
Message-ID: <20090925134352.GA13465@liujiusheng-laptop>
References: <8ff29df80909241953j6c6ce8ebpaa5760504158062e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pawel Pastuszak <pawelpastuszak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:55186 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbZIYNoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 09:44:08 -0400
Received: by fxm18 with SMTP id 18so2203735fxm.17
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2009 06:44:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <8ff29df80909241953j6c6ce8ebpaa5760504158062e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2009 at 10:53:41PM -0400, Pawel Pastuszak wrote:
> Hello everyone,
> 
> I am looking for some help, I am writing an netdev driver and i want
> to known how to i get the current ip  that is set to the device?
> 

use in_dev_get to get in_device;
use macro for_ifa to get the IPv4 address set on the device.

-- 
Liu Jiusheng
