From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: sendfile() behavior while troubleshooting netdevice
Date: Tue, 29 Jul 2008 08:32:34 -0500
Message-ID: <488F1BF2.8090009@bellsouth.net>
References: <20080728190707.329d247b@osprey.hogchain.net> <20080729062804.GA7009@2ka.mipt.ru>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian@jeffray.co.uk
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:53894 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbYG2Nci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 09:32:38 -0400
Received: by wr-out-0506.google.com with SMTP id 69so4266120wri.5
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 06:32:37 -0700 (PDT)
In-Reply-To: <20080729062804.GA7009@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi Jay.
> 
> On Mon, Jul 28, 2008 at 07:07:07PM -0500, Jay Cliburn (jacliburn@bellsouth.net) wrote:
>> sendfile() + TSO + atl1 driver == corrupted file at the receiver
> 
> ...
> 
>> The hosts:
>> server, petrel,  r8169, 192.168.1.6,   2.6.20-1.2320.fc5
>> client, sparrow, e100,  192.168.1.195, 2.6.25.6-27.fc8
> 
> ...
> 
>> [jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
>> connected...
>> file size is 1600 bytes
>> received 1592 bytes
>> error: expected 1600, received 1592
> 
> I.e. trouble also happens with r8169 driver?
> 

I think you may be right, Evgeniy.  I thought I had tested things using 
e100 as the server side, but apparently I didn't.  If I run the server 
from the e100 host, it works flawlessly every time.  (But of course, the 
NIC doesn't support TSO, either.)

More testing tonight...

Thanks.
