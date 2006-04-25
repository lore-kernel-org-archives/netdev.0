From: Rick Jones <rick.jones2@hp.com>
Subject: Re: is it a backwards compatability catch-22?
Date: Mon, 24 Apr 2006 17:38:16 -0700
Message-ID: <444D6F78.9080309@hp.com>
References: <444D6396.4010004@hp.com> <20060424165407.202a86f4@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:49304 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932131AbWDYAiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 20:38:19 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060424165407.202a86f4@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The udev stuff runs after the device has already chosen it's default name.
> It has to, it's part of the hotplug infrastructure, and we don't want
> to depend on usermode to define the name.  Just choose some other
> convention "eth_0"  or something like that.

Is that because adding another NIC at a later time might cause it to 
grab ethN out from under what I'm trying to do with udev?

rick jones
