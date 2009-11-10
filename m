From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 12:37:03 -0600
Message-ID: <4AF9B2CF.6050305@nortel.com>
References: <4AF9A63B.6010101@nortel.com> <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:34903 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757584AbZKJSii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:38:38 -0500
In-Reply-To: <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2009 11:53 AM, Ben Hutchings wrote:
> On Tue, 2009-11-10 at 11:43 -0600, Chris Friesen wrote:

>> Given that a userspace application can be stopped and restarted at any
>> time, and a sunrpc registration can happen at any time, what is the
>> expected mechanism to prevent the kernel from allocating a port for use
>> by sunrpc that reserved or well-known?
>>
>> Apparently Redhat and Debian have distro-specific ways of dealing with
>> this, but is there a standard solution?  Should there be?
>>
>> The current setup seems suboptimal.
> 
> I believe both RH and Debian are using the same implementation:
> <http://cyberelk.net/tim/software/portreserve/>.

That helps with the startup case, but still leaves a possible hole if an
app using a fixed port number is restarted at runtime.  During the
window where nobody is bound to the port, the kernel could randomly
assign it to someone else.

Chris
