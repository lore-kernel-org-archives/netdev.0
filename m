From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Scaling the Number of Network Interfaces on Linux
Date: Wed, 10 Feb 2016 12:59:48 +0100
Message-ID: <56BB2634.3080500@cumulusnetworks.com>
References: <56BB1BEB.5090200@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36203 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbcBJL7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 06:59:54 -0500
Received: by mail-wm0-f43.google.com with SMTP id p63so24999995wmp.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 03:59:54 -0800 (PST)
In-Reply-To: <56BB1BEB.5090200@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/10/16 12:15 PM, Nicolas Dichtel wrote:
> to follow your talk at nedev11, I already proposed some times ago a
> patch to
> remove sysctl, which was rejected. You can see the thread here:
> http://thread.gmane.org/gmane.linux.network/285840

Thanks for the reference. I'll take a look.

>
> Instead of removing completly the sysctl entries, another idea could be to
> manage a group of interfaces which will share the same subtree.

This come out from a side conversation as well -- for example to have 
interfaces enslaved to a bridge or bond share the same devconf.

This is certainly possible to do and I can give it a look. The key point 
is that we clearly need a means to lighten the overhead of a network 
interface.

David
