From: Elad Lahav <elad_lahav@users.sourceforge.net>
Subject: Re: ip_append_page and the socket send buffer
Date: Fri, 16 Feb 2007 17:00:52 -0500
Message-ID: <45D62994.6000609@users.sourceforge.net>
References: <45D60DED.7050709@users.sourceforge.net> <Pine.LNX.4.64.0702161627340.5602@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from services110.cs.uwaterloo.ca ([129.97.152.166]:41652 "EHLO
	services110.cs.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932641AbXBPWBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 17:01:03 -0500
In-Reply-To: <Pine.LNX.4.64.0702161627340.5602@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 16 Feb 2007, Elad Lahav wrote:
> 
>> I wrote a function that is equivalent to udp_sendmsg, but uses ip_append_page
>> to attach data to an skb. The function is implemented as follows:
> 
> Why?

This scheme allows you to send the same data to multiple recipients. The 
user's data is copied only once into a set of pages, which are then 
shared among multiple skbuff objects.

> Where is the code?
The code is probably too long to be attached to a mailing list message. 
It pretty much follows the steps I specified in my original e-mail. I 
can provide more details, if required.

Elad

