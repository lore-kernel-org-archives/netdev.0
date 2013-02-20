From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: why is it not allowed to add a new socket protocol family as an
 external module?
Date: Wed, 20 Feb 2013 15:23:25 -0800
Message-ID: <20130220152325.64c57d55@samsung-9>
References: <5125002D.9080008@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:53452 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab3BTXXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 18:23:36 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so3724428dak.2
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 15:23:35 -0800 (PST)
In-Reply-To: <5125002D.9080008@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2013 10:56:13 -0600
Chris Friesen <chris.friesen@genband.com> wrote:

> Hi,
> 
> I was just wondering why the kernel doesn't allow a new network protocol 
> family to be loaded as as a kernel module built outside the kernel 
> source tree.
> 
> Most of the networking code would seem to allow this, but the check for
> "if (ops->family >= NPROTO)" in sock_register() means that only protocol 
> families defined in socket.h can be registered.
> 
> Was this intentional for ideological reasons, or has nobody wanted to be 
> able to add arbitrary network protocols without patching the kernel and 
> rebuilding?
> 

If you want an answer, to the question, use a tool like cscope and
learn to read the kernel code. There are several tables of pointers sized by NPROTO.
