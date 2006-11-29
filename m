From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hang still exists in 2.6.19-rc6 --Bug#396185?
Date: Tue, 28 Nov 2006 23:03:52 -0800
Message-ID: <456D30D8.20806@osdl.org>
References: <456D1427.70205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56224 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S935306AbWK2HDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 02:03:53 -0500
To: "Berck E. Nash" <flyboy@gmail.com>
In-Reply-To: <456D1427.70205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Berck E. Nash wrote:
> I've been having problems with the sky2 ethernet driver from the very
> beginning.  I have read the following:
>
> http://marc.theaimsgroup.com/?l=linux-netdev&m=116384918914761&w=2
>
> And the bug described still exists for me.  I'm running 2.6.19-rc6-mm1.
>
That motherboard has dual lan, are you using both of them?
I don't have that chip version, so hard to tell if it is using dual port 
with a single chip
or not.  There is a hack for the dual port PCI-X version already in the 
driver,
that turns off receive checksums if both ports are in use. Please try 
turning off
receive checksums with ethtool and see if that helps.
