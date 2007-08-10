From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Fri, 10 Aug 2007 11:11:19 +1000
Message-ID: <18107.47927.676454.739240@notabene.brown>
References: <46BAC0B9.1020207@ext.bull.net>
	<46BB05B6.5080301@oracle.com>
	<46BB2E01.2010406@ext.bull.net>
	<46BB2F65.4080602@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QXVyw6lsaWVuIENoYXJib24=?=
	<aurelien.charbon@ext.bull.net>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:33492 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758112AbXHJBLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 21:11:32 -0400
In-Reply-To: message from Chuck Lever on Thursday August 9
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday August 9, chuck.lever@oracle.com wrote:
> >>
> >> How have you tested the effectiveness of the new hash function?
> > 
> > I have not tested that point but I can easily imagine there are better 
> > solutions.
> > Perhaps we can keep the same function for an IPv4 address (only taking 
> > the 32 bits of IPv4 addr), and then design one for IPv6 addresses.
> 
> I see that, to generate the hash, you would be xor-ing the FF and 00 
> bytes in the canonicalized IPv4 address.  Yes, perhaps a better function 
> is needed, or as you say, one specifically for IPv6 and one for 
> canonicalized IPv4.
> 

I suspect that the given hash function will be as good as any other.
The values in each byte of an IPv6 are likely to be either evenly
distributed, or constant.
Each the first case you don't need a clever hash function to
distribute them, while in the second, no hash function can improve the
distribution. 

NeilBrown
