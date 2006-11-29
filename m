From: "Berck E. Nash" <flyboy@gmail.com>
Subject: Re: sky2 hang still exists in 2.6.19-rc6 --Bug#396185?
Date: Wed, 29 Nov 2006 14:42:59 -0700
Message-ID: <456DFEE3.5070107@gmail.com>
References: <456D1427.70205@gmail.com> <456D30D8.20806@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:8383 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1758141AbWK2VnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 16:43:03 -0500
Received: by py-out-1112.google.com with SMTP id a29so1543694pyi
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 13:43:03 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <456D30D8.20806@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> That motherboard has dual lan, are you using both of them?
> I don't have that chip version, so hard to tell if it is using dual port 
> with a single chip
> or not.  There is a hack for the dual port PCI-X version already in the 
> driver,
> that turns off receive checksums if both ports are in use. Please try 
> turning off
> receive checksums with ethtool and see if that helps.

I'm only using one port.  The second port is disabled in the BIOS.  The 
problem still occurs with receive checksums off.
